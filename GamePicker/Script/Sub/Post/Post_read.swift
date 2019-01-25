import UIKit
import SwiftyJSON
import Alamofire

class Post_read: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var stack_view: UIStackView! // 전체 스택 뷰
    @IBOutlet var post_view: UIView!
    @IBOutlet var comment_view: UIView!
    @IBOutlet var comment_table: UITableView!
    @IBOutlet var comment_write_view: UIView!
    
    @IBOutlet var post_title: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var updated_at: UILabel!
    @IBOutlet var recommends: UILabel!
    @IBOutlet var comments_1: UILabel!
    @IBOutlet var comments_2: UILabel!
    @IBOutlet var views: UILabel!
    @IBOutlet var disrecommend_but: UIButton!
    @IBOutlet var recommend_but: UIButton!
    @IBOutlet var user_name: UILabel!
    
    @IBOutlet var comment_table_height: NSLayoutConstraint!
    
    // 게시글 identifier
    var post_id : Int = 0
    // 협업 부분
    // 1에서 작성
    lazy var comment_arr : [Comment_VO] = {
        var datalist = [Comment_VO]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 댓글에 유저 이름 추가
        user_name.text = UserDefaults.standard.string(forKey: data.user.name)
        // 그림자 추가
        //post_view.dropShadow()
        
        // 스택뷰 로딩 전까지 hidden
        stack_view.isHidden = true
        
        // 추천 비추천 버튼 경계 색 추가
        disrecommend_but.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        recommend_but.layer.borderColor  = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        comment_write_view.layer.borderColor  = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        
        // post id 판별
        switch post_id {
        case 0: showalert(message: "게시글 읽기 오류", can: 0)
        default:
            get_post()
            get_post_comment()
            break
        }
    }
    
    // 게시글 get
    func get_post() {
        Alamofire.request(Api.url + "posts/\(post_id)").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                if response.response?.statusCode == 200 {
                    self.post_title.text = json["post"]["title"].stringValue
                    
                    self.value.text      = json["post"]["value"].stringValue
                    self.name.text       = json["post"]["name"].stringValue
                    self.recommends.text = json["post"]["recommends"].stringValue
                    self.views.text      = json["post"]["views"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let str = json["post"]["updated_at"].stringValue
                    let date = dateFormatter.date(from: String(str.prefix(19)))
                    self.updated_at.text = date?.relativeTime
    
                    
                    self.recommend_but.setTitle(json["post"]["recommends"].stringValue, for: .normal)
                    self.disrecommend_but.setTitle(json["post"]["disrecommends"].stringValue, for: .normal)
                    
                    self.stack_view.isHidden = false
                    
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
    
    // 게시글 댓글 get
    func get_post_comment() {
        Alamofire.request(Api.url + "posts/\(post_id)/comments").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    let comments = json["comments"].arrayValue
                    
                    switch comments.count {
                    case 0:
                        self.comment_table.isHidden = true
                        self.comments_1.text = "0"
                        self.comments_2.text = "0"
                    default:
                        self.comments_1.text = String(comments.count)
                        self.comments_2.text = String(comments.count)
                        for subjson in comments {
                            let comment = Comment_VO()
                            comment.comment_id    = subjson["id"].intValue
                            comment.comment_value = subjson["value"].stringValue
                            comment.recommends    = subjson["recommends"].intValue
                            comment.disrecommends = subjson["disrecommends"].intValue
                            comment.updated_at    = subjson["updated_at"].stringValue
                            comment.user_name     = subjson["name"].stringValue
                            comment.user_id       = subjson["user_id"].stringValue
                            
                            self.comment_arr.append(comment)
                        }
                        self.comment_table.reloadData()
                    }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment_arr.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            // 마지막 셀 로드 완료 했을때
            comment_table_height.constant = (tableView.contentSize.height + 30)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment_cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
        
        let row = self.comment_arr[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let str: String = row.updated_at!
        let date = dateFormatter.date(from: String(str.prefix(19)))
        comment_cell.date.text = date?.relativeTime
        comment_cell.name.text = row.user_name
        comment_cell.value.text = row.comment_value
        
        comment_cell.score.text = "\(row.recommends! - row.disrecommends!)"
        
        
        return comment_cell
    }
    
    @IBAction func recommend(_ sender: Any) {
        // 추천
    }
    
    @IBAction func disrecommend(_ sender: Any) {
        // 비추천
    }
}
