import UIKit
import Firebase
import FBSDKLoginKit

class LogOut: UIViewController,FBSDKLoginButtonDelegate {
    @IBOutlet var Create: UIButton!
    @IBOutlet var Face: FBSDKLoginButton!
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Create.layer.cornerRadius = 4
        Face.layer.cornerRadius   = 4
        
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
        Face.backgroundColor  = UIColor.black
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult?, error: Error!) {
        if (result?.token == nil) { return }
        if (error != nil) { return }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil { return }
            FBSDKLoginManager().logOut();
            let user = Auth.auth().currentUser
            self.User_data.set(user?.displayName, forKey: "User_name")
            self.User_data.set(user?.email, forKey: "User_email")
            self.User_data.set(user?.uid, forKey: "User_uid")
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        // ====================================================
        //FBSDKProfile.loadCurrentProfile { (profile, error) in
        //    self.User_data.set(profile?.name, forKey: "User_name")
        //    self.User_data.synchronize()
        //}  페이스북 프로필 정보
        // ====================================================
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
}
