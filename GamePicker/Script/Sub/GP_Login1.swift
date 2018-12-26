import UIKit

class GP_Login1: UIViewController,UITextFieldDelegate {
    @IBOutlet var email_textfield: UITextField!
    @IBOutlet var password_textfield: UITextField!
    @IBOutlet var login_o: UIButton!
    @IBOutlet var warn: UILabel!
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warn.isHidden = true
        
        email_textfield.placeholder = "E-mail"
        password_textfield.placeholder = "Password"
        
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

    @IBAction func login_a(_ sender: Any) {
        self.performSegue(withIdentifier: "login", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! GP_Login2
        param.email    = email_textfield.text
        param.password = password_textfield.text
    }
    
    @IBAction func undo(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
