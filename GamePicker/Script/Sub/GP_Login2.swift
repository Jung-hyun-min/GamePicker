import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class GP_Login2: UIViewController {
    
    @IBOutlet var check: UILabel!
    
    let User_data = UserDefaults.standard
    
    var email : String?
    var password : String?
    
    let api = Api_url()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().signIn(withEmail: email!, password: password!, completion: {(result, error) in
            if error != nil { // 로그인 실패시 액션 추가 ..
                self.showalert(message: "이메일 비밀번호 확인\n\(error?.localizedDescription ?? "")")
                return
            }
            
            let user = Auth.auth().currentUser
            
            if user != nil && !user!.isEmailVerified {
                // 계정은 있으나 인증이 안된 유저
                self.showalert(message: "이메일 인증 요망")
                do { try Auth.auth().signOut() }
                catch  { }
            } else if user != nil {
                // API 로그인 request
                self.login()
                
                // 로그인 완료되면 루트뷰컨트롤러 변경
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.showalert(message: "로그인 오류(fb2)")
            }
        })
    }
    
    // login request
    func login() {
        let parameters: [String: Any] = [
            "email" : email ?? "",
            "password" : password ?? ""
        ]
        
        Alamofire.request(api.pre + "login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                print(response.result.value ?? "")
                let json = JSON(response.result.value!)
                
                self.syncronize()
                
                let token = json["data"].stringValue
                
                self.User_data.set(token, forKey: "User_token")
            } else {
                self.showalert(message: "로그인 오류(api)")
            }
        }
    }
    
    // 동기화
    func syncronize() {
        // 유저 디포트 삭제
        self.User_data.removeObject(forKey: "User_name")
        self.User_data.removeObject(forKey: "User_email")
        self.User_data.removeObject(forKey: "User_id")
        self.User_data.removeObject(forKey: "User_token")
        self.User_data.removeObject(forKey: "User_sex")
        self.User_data.removeObject(forKey: "User_intro")
        self.User_data.removeObject(forKey: "User_back_picture")
        self.User_data.removeObject(forKey: "User_front_picture")
        
    }
    
    // 알림창 보이기
    func showalert(message : String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(ok)
        self.present(alert,animated: true)
        return
    }
}
