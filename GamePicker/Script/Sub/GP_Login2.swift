import UIKit
import Firebase

class GP_Login2: UIViewController {
    @IBOutlet var check: UILabel!
    
    let User_data = UserDefaults.standard
    
    var email : String?
    var password : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().signIn(withEmail: email!, password: password!, completion: {(result, error) in
            if error != nil { // 로그인 실패시 액션 추가 ..
                
                self.navigationController?.popViewController(animated: true)
                print("=======================")
                print(error.debugDescription)
                print(error?.localizedDescription ?? "")
                print("=======================")
                return
                
            }
            let user = Auth.auth().currentUser
            if user != nil && !user!.isEmailVerified {
                do { try Auth.auth().signOut() }
                catch  { }
                self.navigationController?.popViewController(animated: true)
                let alert = UIAlertController(title: "경고", message: "이메일 인증 필요", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(cancel)
                self.present(alert,animated: true)
                
            } else if user != nil { // 로그인 완료 ( 동기화 작업 )
                // 동기화 ======
                // 유저 디포트 삭제
                self.User_data.removeObject(forKey: "User_name")
                self.User_data.removeObject(forKey: "User_email")
                self.User_data.removeObject(forKey: "User_intro")
                self.User_data.removeObject(forKey: "User_back_picture")
                self.User_data.removeObject(forKey: "User_front_picture")
                // 이름 설정 ...
                self.User_data.set(user?.displayName, forKey: "User_name")
                // 동기화 =======
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "경고", message: "로그인 오류", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(cancel)
                self.present(alert,animated: true)
                self.navigationController?.popViewController(animated: true)

            }
        })
    }
    

}
