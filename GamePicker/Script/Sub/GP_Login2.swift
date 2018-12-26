import UIKit
import Alamofire
import SwiftyJSON

class GP_Login2: UIViewController {
    
    @IBOutlet var check: UILabel!
    
    var email : String?
    var password : String?
    
    let api = Api_url()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // API 로그인 request
        self.login()
        UserDefaults.standard.set(true, forKey: "login")
    }
    
    // login request
    func login() {
        let parameters: [String: Any] = [
            "email" : email ?? "",
            "password" : password ?? ""
        ]
        
        Alamofire.request(api.pre + "login", method: .post, parameters: parameters).responseJSON
            { response in
            if response.result.isSuccess {
                print(response.result.value ?? "")
                let json = JSON(response.result.value!)
                let token = json["data"].stringValue
                self.get_me(token: token)
                UserDefaults.standard.set(token, forKey: "User_token")
            } else {
                self.showalert(message: "로그인 오류",can: 0)
            }
        }
    }
    
    // 유저 정보 받아옴
    func get_me(token : String){
        let heads : [String: String] = [
            "x-access-token" : token
        ]
        
        Alamofire.request(api.pre + "me",headers : heads).responseJSON { (response) in
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
