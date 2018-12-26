import UIKit
import Alamofire
import SwiftyJSON

class Register_second: UIViewController,UITextFieldDelegate {
    @IBOutlet var name_field: UITextField!
    @IBOutlet var warn_stack: UIStackView!
    @IBOutlet var complete: UIButton!
    @IBOutlet var warn_text: UILabel!
    
    @IBOutlet var name_under: UIView!
    
    var mail : String = ""
    var password : String = ""
    
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(endEditing))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        complete.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        
        warn_text.isHidden = true
        warn_stack.isHidden = true
        
        complete.layer.cornerRadius = 6
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @IBAction func back(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "다시입력", style: .default) {
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
    
    @IBAction func complete(_ sender: Any) {
        if name_field.text == "" {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "어떤 글자라도 입력해주세요."
            return
        }
        if name_field.text!.count > 10 {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "10자 이내로 설정해주세요."
            return
        }
        if name_field.text!.count < 3 {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "더 긴 이름을 입력해주세요."
            return
        }
        register()
    }
    
    @objc func endEditing() {
        name_field.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != "" {
            complete.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
            warn_stack.isHidden = true
        }
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 11
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        name_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        name_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
    }
    
    func register() {
        let api = Api_url()
        
        let parameters: [String: Any] = [
            "name" : name_field.text ?? "",
            "email" : mail,
            "password" : password
            ]
        
        Alamofire.request(api.pre + "users", method: .post, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print(response.result.value ?? "")
                let json = JSON(response.result.value!)
                if json["status"].stringValue == "error" {
                    self.showalert(message: json["data"].stringValue, can: 1)
                } else {
                    self.complete_register()
                }
            } else {
                self.showalert(message: "API Register :ERROR", can: 0)
            }
        }
    }
    
    func complete_register() {
        let alert = UIAlertController(title: nil, message: "회원가입 완료", preferredStyle: .alert)
        let ok = UIAlertAction(title: "로그인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.presentingViewController?.dismiss(animated: true)
            let chk = UIApplication.shared.delegate as? AppDelegate
            chk?.check = 1
        }
        alert.addAction(ok)
        
        self.present(alert,animated: true)
        return
    }
    
}
