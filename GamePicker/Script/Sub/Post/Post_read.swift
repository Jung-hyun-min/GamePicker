import UIKit
import Alamofire
import SwiftyJSON

class Post_read: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var name: UILabel!
    @IBOutlet var update: UILabel!
    @IBOutlet var contents: UILabel!
    @IBOutlet var topic: UILabel!
    @IBOutlet var recommend: UILabel!
    @IBOutlet var disrecommend: UILabel!
    
    @IBOutlet var user_message: UILabel!
    
    var post_id : Int = 0
    
    lazy var comment : [Comment_VO] = {
        var datalist = [Comment_VO]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_post()
        get_post_comment()
    }
    
    func get_post() {
        Alamofire.request(Api.url + "posts/\(post_id)").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(response.result.value!)
                if status == "success" {
                    self.name.text = json["data"]["name"].stringValue
                    self.update.text = json["data"]["update_date"].stringValue
                    self.contents.text = json["data"]["content"].stringValue
                    self.topic.text = json["data"]["title"].stringValue
                    self.recommend.text = "\(json["data"]["recommend"].intValue)추"
                    self.disrecommend.text = "\(json["data"]["disrecommend"].intValue)비추"
                }
            } else {
                self.showalert(message: "게시글 데이터 API 오류\n" + response.result.debugDescription, can: 0)
            }
        }
    }
    
    func get_post_comment() {
        Alamofire.request(Api.url + "posts/\(post_id)/comments").responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    
                    if json["data"]["count"].intValue == 0 {
                        self.user_message.text = "아직 댓글이 없습니다."
                        return
                    }
                    
                    for (_,subJson):(String, JSON) in json["data"]["comments"] {
                        let id = subJson["id"].intValue
                        let value = subJson["value"].stringValue
                        let update_date = subJson["update_date"].stringValue
                        let name = subJson["name"].stringValue
                        
                        let com = Comment_VO()
                        
                        com.id = id
                        com.value = value
                        com.update_date = update_date
                        com.name = name
                        
                        self.comment.append(com)
                    }
                    self.table.reloadData()
                    
                } else {
                    self.showalert(message: "코멘트 데이터 조회 API 오류",can: 0)
                }
            } else {
                self.showalert(message: "코멘트 데이터 조회 네트워크(time) 오류",can: 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
        let row = self.comment[indexPath.row]
        
        comment.name.text = row.name
        comment.value.text = row.value
        comment.date.text = row.update_date
        
        
        return comment
    }
    
    @objc func comment_alert_1(sender : UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) {
            (result:UIAlertAction) -> Void in
            self.comment_alert_2(id: sender.tag,which: 1)
        }
        let modify = UIAlertAction(title: "수정", style: .default) {
            (result:UIAlertAction) -> Void in
            self.comment_alert_2(id : sender.tag,which: 2)
        }
        let singo = UIAlertAction(title: "신고", style: .default) {
            (result:UIAlertAction) -> Void in
            self.showalert(message: "준비중인 기능입니다",can: 1)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(delete)
        alert.addAction(modify)
        alert.addAction(singo)
        alert.addAction(cancel)
        self.present(alert,animated: true)
        return
    }
    
    func comment_alert_2(id : Int, which : Int) {
        var message : String = ""
        
        if which == 1 {
            message = "댓글을 삭제하십니까?"
        } else {
            message = ""
        }
        
        let alert = UIAlertController(title: "댓글", message: message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.delete_post_comment(comment_id: id)
        }
        
        let modify = UIAlertAction(title: "수정", style: .destructive) {
            (result:UIAlertAction) -> Void in
            let modify_field = alert.textFields![0]
            
            if modify_field.text == "" {
                alert.message = "수정값이 공백입니다."
            } else {
                self.modify_post_comment(comment_id: id,text: modify_field.text ?? "")
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        if which == 1 {
            alert.addAction(delete)
        } else {
            alert.addTextField { (field) in
                field.placeholder = "수정할 댓글을 입력하세요."
            }
            alert.addAction(modify)
        }
        
        alert.addAction(cancel)
        self.present(alert,animated: true)
        return
    }
    
    // 게시글 댓글 삭제
    func delete_post_comment(comment_id : Int) {
        let heads: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]

        Alamofire.request(Api.url + "posts/\(post_id)/comments/\(comment_id)", method: .delete, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(json)
                if status == "success" {
                    self.comment.removeAll()
                    self.get_post_comment()
                } else {
                    self.showalert(message: "댓글 삭제 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: response.result.debugDescription,can: 0)
            }
        }
    }
    
    // 게시글 댓글 수정
    func modify_post_comment(comment_id : Int,text : String) {
        let heads: [String: String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]
        
        let params: [String: String] = [
            "value" : text
        ]

        Alamofire.request(Api.url + "posts/\(post_id)/comments/\(comment_id)", method: .put, parameters: params, headers: heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print(response.result.value!)
                    self.comment.removeAll()
                    self.get_post_comment()
                } else {
                    self.showalert(message: "댓글 수정 오류\n" + json["data"].stringValue,can: 0)
                }
            } else {
                self.showalert(message: "comment data time error\n" + response.result.description,can: 0)
            }
        }
    }
    
    // 게시글 댓글 삭제
    @IBAction func recommend_post(_ sender: Any) {
        let heads: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]

        Alamofire.request(Api.url + "posts/\(post_id)/recommend", method: .post, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(json)
                if status == "success" {
                    self.showalert(message: "추천 되었습니다.", can: 1)
                    self.view.setNeedsLayout()
                } else {
                    self.showalert(message: "추천 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: response.result.debugDescription,can: 0)
            }
        }
    }
    
    @IBAction func disrecommend_post(_ sender: Any) {
        let heads: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]

        Alamofire.request(Api.url + "posts/\(post_id)/disrecommend", method: .post, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(json)
                if status == "success" {
                    self.view.setNeedsLayout()
                } else {
                    self.showalert(message: "추천 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: response.result.debugDescription,can: 0)
            }
        }
    }
    
    @IBAction func more(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) {
            (result:UIAlertAction) -> Void in
            
        }
        let modify = UIAlertAction(title: "수정", style: .default) {
            (result:UIAlertAction) -> Void in
            
        }
        let singo = UIAlertAction(title: "신고", style: .default) {
            (result:UIAlertAction) -> Void in
            self.showalert(message: "준비중인 기능입니다",can: 1)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(delete)
        alert.addAction(modify)
        alert.addAction(singo)
        alert.addAction(cancel)
        self.present(alert,animated: true)
        return
    }
    /*
    func delete_post(_id : Int) {
        let heads: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]
        let url = api.pre + "games/\(id)/comments/\(comment_id)"
        
        Alamofire.request(url, method: .delete, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(json)
                if status == "success" {
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 삭제 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: response.result.debugDescription,can: 0)
            }
        }
    }
 
    // 게임 댓글 수정
    func modify_(comment_id : Int,text : String) {
        let heads: [String: String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: "User_token") ?? ""
        ]
        
        let params: [String: String] = [
            "value" : text
        ]
        
        //let url = api.pre + "games/\(id)/comments/\(comment_id)"
        
        Alamofire.request(url, method: .put, parameters: params, headers: heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print(response.result.value!)
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 수정 오류\n" + json["data"].stringValue,can: 0)
                }
            } else {
                self.showalert(message: "comment data time error\n" + response.result.description,can: 0)
            }
        }
    }
    */
}
