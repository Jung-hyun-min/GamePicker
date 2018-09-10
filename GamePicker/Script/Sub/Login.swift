import UIKit
import Firebase
import FBSDKLoginKit

class Login: UIViewController,FBSDKLoginButtonDelegate {
    @IBOutlet var Easy: UIButton!
    @IBOutlet var Face: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Face.delegate = self
        
        Easy.layer.cornerRadius = 4
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
    }
    
    @IBAction func Easy_Login(_ sender: Any) { // 게임피커 로그인
        let alert = UIAlertController(title: "로그인", message: "게임피커 계정을 입력하세요.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "로그인", style: .default){
            (result:UIAlertAction) -> Void in
            // 게임피커 로그인차 확인
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        
        alert.addTextField(configurationHandler: {(tf) in
            tf.borderStyle = UITextBorderStyle.roundedRect
            tf.placeholder = "E-mail"
            tf.enablesReturnKeyAutomatically = true
            tf.keyboardType = UIKeyboardType.emailAddress
            tf.isSecureTextEntry = false
        })
        alert.addTextField(configurationHandler: {(tf) in
            tf.borderStyle = UITextBorderStyle.roundedRect
            tf.placeholder = "PassWord"
            tf.keyboardType = UIKeyboardType.alphabet
            tf.isSecureTextEntry = true
            tf.isSecureTextEntry = false
        })
        self.present(alert, animated: true)
    }
    
    @IBAction func Register(_ sender: Any) {
        
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult?, error: Error!) {
        if (result?.token == nil) { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
                //여기는 로그인 되면
                if error != nil {
                    // 에러 날시
                    return
                }
            }
        let User_data = UserDefaults.standard
        FBSDKProfile.loadCurrentProfile { (profile, error) in
            User_data.set(profile?.userID, forKey: "User_ID")
            User_data.set(profile?.name, forKey: "User_name")
            User_data.synchronize()
        }
        FBSDKLoginManager().logOut();
        self.presentingViewController?.dismiss(animated: true)
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
    
}
