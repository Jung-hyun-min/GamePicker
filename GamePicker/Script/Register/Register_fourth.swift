import UIKit
import Alamofire
import SwiftyJSON

class Register_fourth: UIViewController {
    @IBOutlet var name_field: UITextField!
    
    @IBOutlet var warn_stack: UIStackView!
    @IBOutlet var complete: UIButton!
    @IBOutlet var warn_text: UILabel!
    
    @IBOutlet var name_under: UIView!
    
    var mail : String = ""
    var password : String = ""
    var birth : String = ""
    var gender : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: name_field, title: "회원가입")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        complete.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        
        warn_text.isHidden = true
        warn_stack.isHidden = true
        
        complete.layer.cornerRadius = 6
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @IBAction func cancel(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "이름입력 취소", style: .default) {
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
        post_register()
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
    
    func post_register() {
        let parameters: [String: Any] = [
            "email" : mail,
            "name" : name_field.text ?? "",
            "password" : password,
            "birthday" : birth,
            "gender" : "M"
        ]
        
        Alamofire.request(Api.url + "auth/register", method: .post, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    print(json)
                    self.complete_register()
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                self.showalert(message: "서버 응답 오류", can: 0)
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
