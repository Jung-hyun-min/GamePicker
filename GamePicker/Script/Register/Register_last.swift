import UIKit
import Firebase

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
            if error != nil { return }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.User?.name
            changeRequest?.commitChanges { (error) in }
            // 유저 디포트 삭제
            self.User_data.removeObject(forKey: "User_name")
            self.User_data.removeObject(forKey: "User_email")
            self.User_data.removeObject(forKey: "User_intro")
            self.User_data.removeObject(forKey: "User_back_picture")
            self.User_data.removeObject(forKey: "User_front_picture")
            // 이름 설정 ...
            self.User_data.set(self.User?.name, forKey: "User_name")
            // 동기화
            
            Auth.auth().currentUser?.sendEmailVerification( completion: { (error) in
                if error != nil { return }
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
            if error != nil { return }
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
        self.presentingViewController?.dismiss(animated: true)
    }

}
