import UIKit
import Firebase
import Alamofire

class Register_last: UIViewController {
    
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var hello: UILabel!
    @IBOutlet var warn: UILabel!
    @IBOutlet var refresh: UIButton!
    
    let User_data = UserDefaults.standard
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warn.isHidden = true
        refresh.layer.cornerRadius    = 5
        next_but_o.layer.cornerRadius = 5
        next_but_o.isHidden           = true
        hello.text = (User?.name)! + "님"
        
        Auth.auth().createUser(withEmail: (User?.email)!, password: (User?.password)!, completion: {(authResult, error) in
            if error != nil {
                print(error!)
                self.warn.text = "error"
                print("error in create")
                return
            }
            
            self.register() // 가입
            self.register_plus() // 추가 가입
            self.syncronize() // 동기화
            //fb에 이름 설정
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.User?.name
            changeRequest?.commitChanges { (error) in }
 
            Auth.auth().currentUser?.sendEmailVerification( completion: { (error) in
                if error != nil {
                    print("error in sendemail")
                    return
                }
                let user = Auth.auth().currentUser
                if user != nil && !user!.isEmailVerified {
                    do { try Auth.auth().signOut() }
                    catch  { }
                } // 유저 로그아웃
            }) // 메일 보내기
        }) // 계정 생성

    }
    
    @IBAction func refresh_a(_ sender: Any) {
        self.warn.isHidden = false
        self.warn.text = "확인 하고 있어요"
        
        Auth.auth().signIn(withEmail: (User?.email)!, password: (User?.password)!, completion: {(authResult, error) in
            if error != nil {
                self.warn.isHidden = false
                self.warn.text = "오류 : 천천히 해주세요."
                return
            }
            
            let user = Auth.auth().currentUser
            if user != nil && !user!.isEmailVerified {
                self.warn.isHidden = false
                self.warn.text = "아직 인증 안됐어요"
            } else if user == nil {
                self.warn.isHidden = false
                self.warn.text = "오류"
            } else {
                self.warn.text = "인증 됐어요"
                self.warn.isHidden = false
                self.refresh.isHidden = true
                self.next_but_o.isHidden = false
            }
            do { try Auth.auth().signOut() }
            catch  { }
        })
    }

    @IBAction func next_but_o(_ sender: UIButton) {
        User?.check = 1
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // 기본정보 가입
    func register() {
        let parameters: [String: Any] = [
            "name" : User?.name ?? "",
            "email" : User?.email ?? "",
            "password" : User?.password ?? "",
        ]
        
        Alamofire.request("http://gamepicker-api.appspot.com/users", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print(response.result.value ?? "")
            } else {
                print("정보 실패")
            }
            
        }
    }
    
    //추가정보
    func register_plus() {
        let parameters: [String: Any] = [
            "name" : User?.name ?? "",
            "birthday" : User?.birth ?? "",
            "gender" : User?.sex ?? 0,
            "introduce" : ""
            ]
        
        Alamofire.request("http://gamepicker-api.appspot.com/users", method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print(response.result.value ?? "")
                
            } else {
                print("plus 정보 실패")
            }
        }
    }
    //동기화
    func syncronize() {
        // 유저 디포트 삭제
        self.User_data.removeObject(forKey: "User_name")
        self.User_data.removeObject(forKey: "User_email")
        self.User_data.removeObject(forKey: "User_id")
        self.User_data.removeObject(forKey: "User_sex")
        self.User_data.removeObject(forKey: "User_intro")
        self.User_data.removeObject(forKey: "User_back_picture")
        self.User_data.removeObject(forKey: "User_front_picture")
        
        
    }
    
}
