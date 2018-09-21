import UIKit
import Firebase

class Register_nmae: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var name_field: UITextField!
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var warn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warn.isHidden = true
        next_but_o.layer.cornerRadius = 5
        
        name_field.borderStyle = .none
        let border = CALayer()
        border.frame = CGRect(x: 0, y: name_field.frame.size.height-1, width: UIScreen.main.bounds.size.width-120, height: 3)
        border.backgroundColor = UIColor.red.cgColor
        name_field.layer.addSublayer((border))
        name_field.textAlignment = .center
        name_field.textColor = UIColor.black
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

    }
    @IBAction func next_but_a(_ sender: Any) {
        let User = UIApplication.shared.delegate as? AppDelegate
        
        if name_field.text == "" {
            warn.isHidden = false
            warn.text = "어떤 글자라도 입력해주세요."
        } else if name_field.text!.count > 10 {
            warn.isHidden = false
            warn.text = "10자 이내로 설정해주세요."
        } else {
            User?.name = name_field.text!
            self.performSegue(withIdentifier: "birth", sender: self)
        }
    }
    
    @objc func endEditing() {
        name_field.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func back(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "회원가입 취소", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    } // 뒤로 가기
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        warn.isHidden = true
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 11
    }
    
}
