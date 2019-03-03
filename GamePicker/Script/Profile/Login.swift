import UIKit
import Alamofire
import SwiftyJSON
import TransitionButton
import Kingfisher


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

    
    func mail_chk() -> Bool {
        if mail.text!.isEmpty {
            // mail textfield 비었으면
            const_1.constant = 30
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일을 입력하세요."
            return false
        } else {
            // mail textfield 통과
            const_1.constant = 15
            mail_warn_stack.isHidden = true
            return true
        }
    }
    
    func password_chk() -> Bool {
        if password.text!.isEmpty {
            // password textfield 비었으면
            const_2.constant = 40
            password_warn_stack.isHidden = false
            password_warn_text.text = "비밀번호를 입력하세요."
            return false
        } else {
            // password textfield 통과
            const_2.constant = 35
            password_warn_stack.isHidden = true
            return true
        }
    }
    

    func post_login() {
        // 로그인 데이터
        let parameters: [String: Any] = [
            "email": self.mail.text!,
            "password": self.password.text!,
        ]
        
        Alamofire.request(Api.url + "auth/login", method: .post, parameters: parameters, headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                print(json)
                
                if response.response?.statusCode == 200 {
                    print("login succeed")
                    UserDefaults.standard.set(json["user_id"].intValue, forKey: data.user.id) // id
                    UserDefaults.standard.set(json["token"].stringValue, forKey: data.user.token) // 토큰
                    UserDefaults.standard.set(self.password.text!, forKey: data.user.password) // 비밀번호
                    
                    Api.authorization = [
                        "authorization": "w6mgLXNHbPgewJtRESxh",
                        "x-access-token": UserDefaults.standard.string(forKey: data.user.token) ?? ""
                    ]
                    
                    print("synchronize..")
                    
                    self.get_me(id: json["user_id"].intValue) { result in
                        
                        if result {
                            print("synchronize succeed")
                            self.login.stopAnimation(animationStyle: .normal)
                            
                            guard UserDefaults.standard.bool(forKey: data.isPush) else {
                                self.performSegue(withIdentifier: "push", sender: self)
                                return
                            }
                            
                            UserDefaults.standard.set(true, forKey: data.isLogin) // 자동 로그인 활성화
                            
                            self.view.endEditing(true)
                        
                            self.view.window?.rootViewController?.dismiss(animated: false) {
                                guard let window = UIApplication.shared.keyWindow else { return }
                                guard let rootViewController = window.rootViewController else { return }
                                
                                let vc = self.instanceMainVC(name: "tab")
                                vc!.view.frame = rootViewController.view.frame
                                vc!.view.layoutIfNeeded()
                                
                                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                    window.rootViewController = vc
                                })
                            }
                            
                        } else {
                            print("synchronize failed")
                            self.login.stopAnimation(animationStyle: .normal)
                            self.showalert(message: "동기화 실패. 다시 로그인하세요.", can: 0)
                        }
                    }
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json.stringValue, can: 0)
                    self.login.stopAnimation(animationStyle: .shake)
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                    self.login.stopAnimation(animationStyle: .shake)
                }
                
            }
            
            response.result.ifFailure {
                print(response.result.error.debugDescription)
                self.showalert(message: "네트워크 연결 실패", can: 0)
                self.login.stopAnimation(animationStyle: .shake)
                
            }
        }
    }
    
    func get_me(id: Int, completionHandler: @escaping (Bool) -> Void) {
        Alamofire.request(Api.url + "me", headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                print("synchronize..")
                print(json)
                if response.response?.statusCode == 200 {
                    let ud = UserDefaults.standard
                    let user = json["user"].dictionaryValue
                    
                    ud.set(user["points"]?.intValue, forKey: data.user.points)
                    ud.set(user["introduce"]?.stringValue, forKey: data.user.introduce)
                    ud.set(user["gender"]?.stringValue, forKey: data.user.gender)
                    ud.set(user["name"]?.stringValue, forKey: data.user.name)
                    ud.set(user["birthday"]?.stringValue, forKey: data.user.birthday)
                    ud.set(user["email"]?.stringValue, forKey: data.user.email)
                    ud.set(user["profile"]?.stringValue, forKey: data.user.profile)
                    
                    completionHandler(true)
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    completionHandler(false)
                } else {
                    completionHandler(false)
                }
            }
            
            response.result.ifFailure {
                completionHandler(false)
            }
        }
    }
}


extension Login: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}
