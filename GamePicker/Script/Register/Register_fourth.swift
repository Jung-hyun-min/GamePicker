import UIKit
import Alamofire
import SwiftyJSON

class Register_fourth: UIViewController {
    @IBOutlet var name_field: UITextField!
    
    @IBOutlet var warn_stack: UIStackView!
    @IBOutlet var complete: UIButton!
    @IBOutlet var warn_text: UILabel!
    
    @IBOutlet var name_under: UIView!
    
    var mail: String = ""
    var password: String = ""
    var birth: String = ""
    var gender: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: name_field, title: "회원가입")
        hideKeyboard_tap()
    }
    
    override func barPressed() {
        complete(self)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "이름입력 취소", style: .default) { UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        
        let ok2 = UIAlertAction(title: "회원가입 취소", style: .destructive) { UIAlertAction in
            self.presentingViewController?.dismiss(animated: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addAction(ok2)
        self.present(alert,animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        if name_field.text!.isEmpty {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "필수입력 항목입니다."
            return
        } else if name_field.text!.count > 15 {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "15자 이내로 설정하세요."
            return
        } else if name_field.text!.count < 3 {
            warn_text.isHidden = false
            warn_stack.isHidden = false
            warn_text.text = "3자 이상의 이름을 입력하세요."
            return
        }
        
        get_name_isOverlap { result in
            if result {
                // 이름 중복 체크
                self.warn_text.isHidden = false
                self.warn_stack.isHidden = false
                self.warn_text.text = "이미 존재하는 닉네임 입니다."
            } else {
                self.post_register()
            }
        }
    }
    
    
    func complete_register() {
        let alert = UIAlertController(title: nil, message: "회원가입 완료", preferredStyle: .alert)
        let ok = UIAlertAction(title: "로그인", style: .default) {
            (result:UIAlertAction) -> Void in
            weak var pvc = self.presentingViewController
            self.presentingViewController?.dismiss(animated: true) {
                pvc?.performSegue(withIdentifier: "login", sender: self)
            }
        }
        
        alert.addAction(ok)
        
        self.present(alert,animated: true)
        return
    }
    
    
    func post_register() {
        let parameters: [String: Any] = [
            "email": mail,
            "name": name_field.text!,
            "password": password,
            "birthday": birth,
            "gender": gender
        ]
        
        Alamofire.request(Api.url + "auth/register", method: .post, parameters: parameters, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    self.complete_register()
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 1)
                } else {
                    self.showalert(message: "서버 오류", can: 1)
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
    
    func get_name_isOverlap(completionHandler: @escaping (Bool) -> Void ) {
        let urlstr = Api.url + "users?name=" + name_field.text!
        let encoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URL(string: encoded)!, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? "")
                if response.response?.statusCode == 200 {
                    let arr = json["users"].arrayValue
                    
                    if arr.count == 1 { completionHandler(true) }
                    else { completionHandler(false) }
                    
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}



extension Register_fourth: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        name_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        if name_field!.text == "\u{C190} \u{D76C} \u{C5F0}" {
            textField.text?.append("\u{1F496}")
        }
        
        if (textField.text?.isEmpty)! {
            complete.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        } else {
            complete.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        name_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
    }
}

