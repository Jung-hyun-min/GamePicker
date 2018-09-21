import UIKit
import Firebase

class Register_password: UIViewController {

    @IBOutlet var warn: UILabel!
    @IBOutlet var password_field: UITextField!
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var hello: UILabel!
    
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hello.text = (User?.name)! + " 님"
        warn.isHidden = true
        next_but_o.layer.cornerRadius = 5
        
        password_field.isSecureTextEntry = true
        password_field.borderStyle = .none
        let border = CALayer()
        border.frame = CGRect(x: 0, y: password_field.frame.size.height-1, width: UIScreen.main.bounds.size.width-120, height: 3)
        border.backgroundColor = UIColor.red.cgColor
        password_field.layer.addSublayer((border))
        password_field.textAlignment = .center
        password_field.textColor = UIColor.black

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @IBAction func undo(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "비밀번호 입력 취소", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        let ok2 = UIAlertAction(title: "회원가입 취소", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addAction(ok2)
        self.present(alert,animated: true)
    }
    
    @IBAction func next_but_a(_ sender: Any) {
        if password_field.text == "" {
            warn.isHidden = false
            warn.text = "어떤 글자라도 입력해주세요"
        } else if password_field.text!.count > 15 {
            warn.isHidden = false
            warn.text = "문자 + 숫자 포함 15자 이내로 설정해주세요"
        } else {
            User?.password = password_field.text
            Auth.auth().createUser(withEmail: (User?.email)!, password: (User?.password)!) { (authResult, error) in
                if error != nil { return }
                self.performSegue(withIdentifier: "verify", sender: self)
            }
        }
    }
    
    @objc func endEditing() {
        password_field.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        warn.isHidden = true
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 16
    }
}
