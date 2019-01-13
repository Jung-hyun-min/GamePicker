import UIKit
import Alamofire
import SwiftyJSON
import TransitionButton

class Login: UIViewController {
    @IBOutlet var mail: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var login: TransitionButton!

    @IBOutlet var mail_under: UIView!
    @IBOutlet var password_under: UIView!

    @IBOutlet var mail_warn_text: UILabel!
    @IBOutlet var password_warn_text: UILabel!
    
    @IBOutlet var mail_warn_stack: UIStackView!
    @IBOutlet var password_warn_stack: UIStackView!
    
    @IBOutlet var const_1: NSLayoutConstraint!
    @IBOutlet var const_2: NSLayoutConstraint!
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolBar(textField: mail, title: "다음")
        addToolBar(textField: password, title: "로그인")
        const_1.constant = 15
        const_2.constant = 25
        
        mail_under.backgroundColor     = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        password_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        
        mail_warn_stack.isHidden     = true
        password_warn_stack.isHidden = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @objc func endEditing() {
        mail.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func login(_ sender: Any) {
        login.startAnimation()
        if mail_chk() && password_chk() {
            self.login.stopAnimation(animationStyle: .normal, completion: {
                self.presentingViewController?.dismiss(animated: true)
            })
            //post_login()
        } else {
            self.login.stopAnimation(animationStyle: .shake)
        }
    }
    
    func mail_chk() -> Bool {
        // 메일 오류 없으면 트루 출력
        if !(mail.text?.contains("@") ?? false) {
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일 형식 오류"
            return false
        }
        return true
    }
    func password_chk() -> Bool {
        // 비밀번호 오류 없으면 트루 출력
        return true
    }
    
    override func barPressed() {
        if mail.isFirstResponder {
            if mail_chk() {
                password.becomeFirstResponder()
            }
        } else {
            login(self)
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mail {
            mail_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        } else {
            password_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mail {
            mail_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        } else {
            password_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
    }
    
    func post_login() {
        let parameters: [String: Any] = [
            "email" : self.mail.text ?? "",
            "password" : self.password.text ?? "",
            "os_type" : "iphone",
            "reg_id" : 0
        ]
        
        Alamofire.request(Api.url + "auth/login", method: .post, parameters: parameters).responseJSON { (response) in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    if response.response?.statusCode == 200 {
                        

                        
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

    func get_me(token : String) {
        let heads : [String: String] = [
            "x-access-token" : token
        ]
        
        Alamofire.request(Api.url + "me",headers : heads).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    let status = json["status"]
                    print(json)
                    if status == "success" {
                        let User_data = UserDefaults.standard
                        User_data.set(json["data"]["point"].intValue, forKey: "User_point")
                        User_data.set((json["data"]["gender"].intValue), forKey: "User_gender")
                        User_data.set(json["data"]["name"].stringValue, forKey: "User_name")
                        User_data.set(json["data"]["email"].stringValue, forKey: "User_email")
                        User_data.set(json["data"]["introduce"].stringValue, forKey: "User_introduce")
                        User_data.set(json["data"]["admin"].boolValue, forKey: "User_admin")
                        User_data.set(String(json["data"]["birthday"].stringValue.prefix(10)), forKey: "User_birthday")
                        User_data.set(json["data"]["premium"].boolValue, forKey: "User_premium")
                        User_data.set(json["data"]["password"].stringValue, forKey: "User_password")
                        User_data.set(json["data"]["id"].intValue, forKey: "User_id")
                        
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.showalert(message: "API 동기화 오류", can: 0)
            }
        }
    }
}
