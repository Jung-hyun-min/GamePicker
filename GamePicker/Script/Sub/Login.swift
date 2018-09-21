import UIKit
import Firebase
import FBSDKLoginKit

class Login: UIViewController,FBSDKLoginButtonDelegate {
    @IBOutlet var Create: UIButton!
    @IBOutlet var Face: FBSDKLoginButton!
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Create.layer.cornerRadius = 4
        Face.layer.cornerRadius = 4
        
        // 높이 잠금 해제
        for const in Face.constraints{
            if const.firstAttribute == NSLayoutAttribute.height && const.constant == 28{
                Face.removeConstraint(const)
            }
        }
        // 타이틀 잠금 해제
        let buttonText = NSAttributedString(string: "페이스북으로 로그인")
        Face.setAttributedTitle(buttonText, for: .normal)
        // 타이틀 폰트 크기 설정
        Face.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        Face.backgroundColor = UIColor.black
    }
    
    @IBAction func Easy_Login(_ sender: Any) { // 게임피커 로그인
        let alert = UIAlertController(title: "로그인", message: "게임피커 계정을 입력하세요.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "로그인", style: .default){
            (result:UIAlertAction) -> Void in
            
            let email = alert.textFields?[0].text
            let password = alert.textFields?[1].text
            Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { (user, error) in
                if error != nil { print("failed")
                    return } // 실패시 액션 추가
                print("Success")
            }
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextField(configurationHandler: {(tf) in
            tf.placeholder = "E-mail"
            tf.enablesReturnKeyAutomatically = true
            tf.keyboardType = UIKeyboardType.emailAddress
            tf.isSecureTextEntry = false
        })
        alert.addTextField(configurationHandler: {(tf) in
            tf.placeholder = "PassWord"
            tf.keyboardType = UIKeyboardType.alphabet
            tf.isSecureTextEntry = true
            tf.isSecureTextEntry = false
        })
        self.present(alert, animated: true)
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult?, error: Error!) {
        if (result?.token == nil) { return }
        if (error != nil) { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil { return }
            let user = Auth.auth().currentUser
            self.User_data.set(user?.displayName, forKey: "User_name")
            self.User_data.set(user?.email, forKey: "User_email")
            self.User_data.set(user?.uid, forKey: "User_uid")
        }
        //
        //FBSDKProfile.loadCurrentProfile { (profile, error) in
        //    self.User_data.set(profile?.name, forKey: "User_name")
        //    self.User_data.synchronize()
        //}
        // 페이스북 프로필 정보
        self.presentingViewController?.dismiss(animated: true)
        FBSDKLoginManager().logOut();
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
}
