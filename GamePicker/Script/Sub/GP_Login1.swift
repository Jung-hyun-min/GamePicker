import UIKit
import Firebase

class GP_Login1: UIViewController {
    
    @IBOutlet var email_textfield: UITextField!
    @IBOutlet var password_textfield: UITextField!
    @IBOutlet var login_o: UIButton!
    @IBOutlet var warn: UILabel!
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warn.isHidden = true
        login_o.layer.cornerRadius = 5
        
        email_textfield.placeholder = "E-mail"
        email_textfield.borderStyle = .none
        let border1 = CALayer()
        border1.frame = CGRect(x: 0, y: email_textfield.frame.size.height-1, width: UIScreen.main.bounds.size.width - 120, height: 3)
        border1.backgroundColor = UIColor.red.cgColor
        email_textfield.layer.addSublayer((border1))
        email_textfield.textAlignment = .center
        email_textfield.textColor     = UIColor.black

        password_textfield.placeholder = "Password"
        password_textfield.borderStyle = .none
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: password_textfield.frame.size.height-1, width: UIScreen.main.bounds.size.width - 120, height: 3)
        border2.backgroundColor = UIColor.red.cgColor
        password_textfield.layer.addSublayer((border2))
        password_textfield.textAlignment = .center
        password_textfield.textColor     = UIColor.black
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @objc func endEditing() {
        email_textfield.resignFirstResponder()
        password_textfield.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        warn.isHidden = true
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 36
    }

    @IBAction func login_a(_ sender: Any) {
        let email = email_textfield.text
        let password = password_textfield.text
        if email == "" || password == "" {
            warn.isHidden = false
            warn.text = "입력해주세요"
        } else if (email?.count)! > 35 {
            warn.isHidden = false
            warn.text = "메일이 너무 길어요"
        } else if (password?.count)! > 20 {
            warn.isHidden = false
            warn.text = "비밀번호가 너무 길어요"
        } else if (email?.count)! < 9 {
            warn.isHidden = false
            warn.text = "메일이 너무 짧아요"
        } else if (password?.count)! < 4 {
            warn.isHidden = false
            warn.text = "비밀번호가 너무 짧아요"
        } else {
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! GP_Login2
        param.email    = email_textfield.text
        param.password = password_textfield.text
    }
    
    @IBAction func undo(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    } // 뒤로가기
}
