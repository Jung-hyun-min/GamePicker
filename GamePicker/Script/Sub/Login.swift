import UIKit
import Alamofire
import SwiftyJSON
import TransitionButton
import Firebase

class Login: UIViewController {
    @IBOutlet var mail: UITextField! // 메일 입력 텍스트 필드
    @IBOutlet var password: UITextField! // 비밀번호 텍스트 필드
    
    @IBOutlet var login: TransitionButton! // 로그인 버튼

    @IBOutlet var mail_under: UIView! // 메일 텍스트 필드 언더 바
    @IBOutlet var password_under: UIView! // 비밀번호 텍스트 필드 언더 바

    @IBOutlet var mail_warn_text: UILabel! // 메일 경고 스택 텍스트
    @IBOutlet var password_warn_text: UILabel! // 비밀벙호 경고 스택 텍스트
    
    @IBOutlet var mail_warn_stack: UIStackView! // 메일 경고 스택
    @IBOutlet var password_warn_stack: UIStackView! // 비밀번호 경고 스택
    
    @IBOutlet var const_1: NSLayoutConstraint! // 레이아웃 constraint
    @IBOutlet var const_2: NSLayoutConstraint! // 레이아웃 constraint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 키보드에 툴바 추가
        addToolBar(textField: mail, title: "다음")
        addToolBar(textField: password, title: "로그인")

        // 키보드 제외 화면 터치 시 키보드 숨김
        hideKeyboard_tap()
    }
    
    // 키보드 리턴 버튼 누를 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // 로그인 액션 함수
    @IBAction func login(_ sender: Any) {
        // 메일 비밀번호 체크
        if mail_chk() && password_chk() {
            // 성공시 로그인 post
            // 로그인 버튼 애니메이션 시작
            login.startAnimation()
            post_login()
        } else {
            // 실패하면 로그인 버튼 shake
            self.login.shake(0.5)
        }
    }
    
    // 메일 오류 없으면 트루 리턴
    func mail_chk() -> Bool {
        if mail.text!.isEmpty {
            const_1.constant = 30
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일을 입력하세요."
            return false
        } else if !(mail.text?.contains("@") ?? false) {
            const_1.constant = 30
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일 형식 오류."
            return false
        } else {
            const_1.constant = 15
            mail_warn_stack.isHidden = true
            return true
        }
    }
    // 비밀번호 오류 없으면 트루 리턴
    func password_chk() -> Bool {
        if password.text!.isEmpty {
            const_2.constant = 40
            password_warn_stack.isHidden = false
            password_warn_text.text = "비밀번호를 입력하세요."
            return false
        } else {
            const_2.constant = 25
            password_warn_stack.isHidden = true
            return true
        }
    }
    
    // 키보드 툴바 버튼 클릭시 실행 함수
    override func barPressed() {
        if mail.isFirstResponder {
            if mail_chk() {
                password.becomeFirstResponder()
            }
        } else {
            login(self)
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mail {
            mail_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        } else {
            password_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mail {
            mail_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        } else {
            password_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
    }
    
    func post_login() {
        // 토큰값 추출 *푸시알림관련* 2019-1-20 최종수정
        var reg_id: String?
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                reg_id = result.token
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        // 로그인 데이터
        let parameters: [String: Any] = [
            "email" : self.mail.text!,
            "password" : self.password.text!,
            "os_type" : "iphone",
            "reg_id" : reg_id ?? "null"
        ]
        
        Alamofire.request(Api.url + "auth/login", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    print(json)
                    if response.response?.statusCode == 200 {
                        // User default 에 저장
                        UserDefaults.standard.set(json["user_id"].intValue, forKey: data.user.id)
                        UserDefaults.standard.set(json["token"].stringValue, forKey: data.user.token)
                        
                        // 내정보 get 컴플리션 추가 앙망
                        self.get_me(id: json["user_id"].intValue) { result in
                            if result {
                                // 유저 동기화 성공
                                // get 끝나면 로그인 애니메이션 중지
                                self.login.stopAnimation(animationStyle: .normal)
                                // 자동로그인 활성화
                                UserDefaults.standard.set(true, forKey: data.isLogin)
                                // 애니메이션 끝나면 화면 뒤로
                                self.view.window?.rootViewController?.dismiss(animated: true)
                            }
                        }
                        
                    } else if response.response?.statusCode ?? 0 < 500 {
                        self.showalert(message: json["message"].stringValue, can: 0)
                        self.login.stopAnimation(animationStyle: .shake)
                    } else {
                        self.showalert(message: "서버 오류", can: 0)
                        self.login.stopAnimation(animationStyle: .shake)
                    }
                } else {
                    self.showalert(message: "서버 응답 오류", can: 0)
                    self.login.stopAnimation(animationStyle: .shake)
                }
        }
    }
    
    
    func get_me(id : Int, completionHandler : @escaping (Bool) -> Void) {
        Alamofire.request(Api.url + "users/\(id)").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    let ud = UserDefaults.standard
                    let user = json["user"].dictionaryValue
                    print(user)
                    ud.set(user["points"]?.intValue, forKey: data.user.points)
                    ud.set(user["introduce"]?.string, forKey: data.user.introduce)
                    ud.set(user["profile"]?.string, forKey: data.user.profile)
                    ud.set(user["gender"]?.string, forKey: data.user.gender)
                    ud.set(user["name"]?.string, forKey: data.user.name)
                    ud.set(user["birthday"]?.string, forKey: data.user.birthday)
                    ud.set(user["email"]?.string, forKey: data.user.email)
                    completionHandler(true)
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                self.showalert(message: "서버 응답 오류", can: 0)
            }
        }
    }
}
