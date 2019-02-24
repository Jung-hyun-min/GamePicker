import UIKit
import SwiftyJSON
import Alamofire

class Post_write: UIViewController {
    @IBOutlet var post_title: UITextField!
    @IBOutlet var post_value: UITextView!
    @IBOutlet var value_under: NSLayoutConstraint!

    var isEdit: Bool?
    var category: String?
    var game_id: Int?
    var edit_id: Int?
    var edit_title: String?
    var edit_value: String?
    
    var delegate: IsreloadDataDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = ""
        
        switch isEdit {
        case true:
            post_title.text = edit_title
            post_value.text = edit_value
            
        default: break
        }
    }
    
    
    @IBAction func write(_ sender: Any) {
        post_post()
    }
    
    @IBAction func cancle(_ sender: Any) {
        guard !post_value.text.isEmpty || !(post_title.text?.isEmpty)! else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(title: "알림", message: "글쓰기를 취소하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "아니요", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
    
    
    func post_post() {
        let parameter: [String: Any] = [
            "title": post_title.text!,
            "value": post_value.text!,
            "game_id": game_id!,
            "category": category!
        ]
        
        Alamofire.request(Api.url + "posts", method: .post, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                if response.response?.statusCode == 204 {
                    self.delegate?.reload()
                    self.navigationController?.popViewController(animated: true)
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                    
                } else {
                    print(response.response?.statusCode ?? 0)
                    self.showalert(message: "서버 오류", can: 0)
    
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
                print(response.result.debugDescription)
            }
        }
    }
}


extension Post_write: UITextViewDelegate {
    
}

extension Post_write: UITextFieldDelegate {
    
}
