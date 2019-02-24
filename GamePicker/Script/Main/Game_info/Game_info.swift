import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import Kingfisher
import youtube_ios_player_helper

class Game_info: UIViewController,UIScrollViewDelegate {
    @IBOutlet var container_view: UIView!
    @IBOutlet var container_scroll: UIScrollView!
    @IBOutlet var comtainer_stack: UIStackView!
    
    @IBOutlet var game_view: UIView!
    @IBOutlet var stack_view: UIView!
    @IBOutlet var comment_table: UITableView!
    @IBOutlet var message1_view: UIView!
    @IBOutlet var detail_view: UIView!
    @IBOutlet var video_view: UIView!
    @IBOutlet var summary_view: UIView!
    @IBOutlet var message2_view: UIView!
    @IBOutlet var comment_util_view: UIView!

    
    @IBOutlet var favorite_image: UIImageView!
    @IBOutlet var evaluate_image: UIImageView!
    @IBOutlet var community_image: UIImageView!
    
    @IBOutlet var favorite_but: User_stack_but!
    @IBOutlet var evaluate_but: User_stack_but!
    @IBOutlet var community_but: User_stack_but!
    
    @IBOutlet var game_image: UIImageView!
    @IBOutlet var game_title: UILabel!
    @IBOutlet var game_score: UILabel!
    @IBOutlet var game_score_count: UILabel!
    @IBOutlet var game_age: UILabel!
    @IBOutlet var game_platform: UILabel!
    @IBOutlet var game_developer: UILabel!
    @IBOutlet var game_publisher: UILabel!
    @IBOutlet var game_summary: UILabel!
    @IBOutlet var game_video: YTPlayerView!
    
    @IBOutlet var game_myscore_view: UIView!
    @IBOutlet var game_myscore: UILabel!
    
    @IBOutlet var comment_num: UILabel!
    @IBOutlet var comment_toolbar: UIView!
    @IBOutlet var comment_textview: UITextView!
    @IBOutlet var comment_send: UIButton!
    @IBOutlet var comment_resign: UIButton!

    @IBOutlet var comment_down: NSLayoutConstraint!
    @IBOutlet var comment_right: NSLayoutConstraint!
    @IBOutlet var comment_left: NSLayoutConstraint!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    
    let stack_functions = User_stack()
    var comment_textIsempty: Bool = true
    let placeholder: String = "\(UserDefaults.standard.string(forKey: data.user.name)!)님의 게임 게임리뷰를 적어주세요."
    var game_id: Int?
    var comment_arr = [Comment_VO]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = ""
        container_scroll.isHidden = true
        
        get_game() // 게임 get
        get_favor() { result in
            if result {
                self.favorite_image.image = UIImage(named: "ic_heart_fill")
                self.favorite_but.isDone = true
            } else {
                self.favorite_image.image = UIImage(named: "ic_heart_empty")
                self.favorite_but.isDone = false
            }
        }
        get_score { result in
            if result == 0 {
                self.game_myscore_view.isHidden = true
                self.evaluate_but.isDone = false
            } else {
                self.game_myscore_view.isHidden = false
                self.game_myscore.text = String(result)
                self.evaluate_but.self_myscore_value = result
                self.evaluate_but.isDone = true
            }
        }
        
        stack_functions.parent = self
        favorite_but.addTarget(stack_functions, action: #selector(stack_functions.favorite(_:)), for: .touchUpInside)
        evaluate_but.addTarget(stack_functions, action: #selector(stack_functions.evaluate(_:)), for: .touchUpInside)
        community_but.addTarget(stack_functions, action: #selector(stack_functions.community(_:)), for: .touchUpInside)
        
        comment_toolbar.layer.borderColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1).cgColor
        comment_textview.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        comment_textview.text = placeholder
        comment_textview.textColor = UIColor.lightGray
        
        // user_stack 파라미터 처리
        self.favorite_but.self_image = self.favorite_image
        self.favorite_but.game_id = self.game_id
        
        self.evaluate_but.game_id = self.game_id
        self.evaluate_but.self_score_value = self.game_score
        self.evaluate_but.self_score_count = self.game_score_count
        self.evaluate_but.self_myscore_view = self.game_myscore_view
        self.evaluate_but.self_myscore = self.game_myscore
        
        self.community_but.game_id = self.game_id
    }
    
    override func viewWillAppear(_ animated: Bool) {
        get_comment() {
            self.comment_table.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func close_message1(_ sender: Any) {
        UIView.animate(withDuration: Double(0.4), animations: {
            self.message1_view.isHidden = true
        })
    }
    
    @IBAction func close_message2(_ sender: Any) {
        UIView.animate(withDuration: Double(0.4), animations: {
            self.message2_view.isHidden = true
        })
    }
    
    @IBAction func review_resign(_ sender: Any) {
        comment_textview.resignFirstResponder()
        UIView.animate(withDuration: Double(0.2), animations: {
            self.comment_right.constant = 30
            self.view.layoutIfNeeded()
        })
        comment_send.isHidden = true
    }
    
    @IBAction func write_comment(_ sender: Any) {
        let comment_text = comment_textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        post_comment(comment_text) {
            custom_alert.red_alert(text: "리뷰 작성 완료")
            self.get_comment() {
                self.comment_table.reloadData()
                    DispatchQueue.main.async() { self.scroll_bottom() }
            }
        }
        
        UIView.animate(withDuration: Double(0.2), animations: {
            self.comment_right.constant = 30
            self.view.layoutIfNeeded()
        })
        
        comment_textview.text = placeholder
        comment_textview.textColor = UIColor.lightGray
        comment_textview.resignFirstResponder()
        comment_textview.text = nil
        
        comment_send.isHidden = true
        comment_textIsempty = true
    }
    
    
    /* 키보드 hide show functions */
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if container_view.frame.size.height-(comment_toolbar.frame.origin.y+comment_toolbar.frame.size.height) == 0 {
            let endFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let kh = endFrame.cgRectValue.height - (tabBarController?.tabBar.frame.size.height)!
            
            UIView.animate(withDuration: 0.3, animations: {
                self.comment_down.constant = kh
                self.comment_left.constant = 65
                self.comment_resign.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification) {
        let endFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let kh = endFrame.cgRectValue.height - (tabBarController?.tabBar.frame.size.height)!
        let th = container_view.frame.size.height-(comment_toolbar.frame.origin.y+comment_toolbar.frame.size.height)
        
        if kh == th {
            self.comment_resign.isHidden = true
            UIView.animate(withDuration: 1.3, animations: {
                self.comment_down.constant = 0
                self.comment_left.constant = 30
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func up_comment(_ sender: UIButton) {
        print("\(sender.tag) like")
        let index = sender.tag
        request_comment_up_down(comment_arr[index].comment_id!, "like", .post) {
            
        }
    }
    
    @objc func down_comment(_ sender: UIButton) {
        print("\(sender.tag) dislike")
        let index = sender.tag
        request_comment_up_down(comment_arr[index].comment_id!, "dislike", .post) {
            
        }
    }
    
    
    func scroll_bottom() {
        if self.container_scroll.contentSize.height > self.container_scroll.bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: self.container_scroll.contentSize.height - self.container_scroll.bounds.size.height)
            self.container_scroll.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    
    /* request functions */
    func get_game() {
        Alamofire.request(Api.url + "games/\(game_id!)", headers: Api.authorization).responseJSON { (response) in
            guard response.result.isSuccess else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
                return
            }
            print("get game succeed")
            let json = JSON(response.result.value!)
            
            if response.response?.statusCode == 200 {
                let title = json["game"]["title"].stringValue
                self.navigationItem.title = title
                self.community_but.game_title = title
                self.evaluate_but.game_title = title
                
                self.game_title.text     = title
                self.game_age.text       = json["game"]["age_rate"].stringValue
                self.game_developer.text = json["game"]["developer"].stringValue
                self.game_publisher.text = json["game"]["publisher"].stringValue
                self.game_summary.text   = json["game"]["summary"].stringValue
                
                // 평점
                let score_value = json["game"]["score"].doubleValue
                let score_count = json["game"]["score_count"].intValue
                self.evaluate_but.game_score_value = score_value
                self.evaluate_but.game_score_count = score_count
                if score_count != 0 {
                    self.game_score.text = String((round(score_value * 100) / 100))
                    self.game_score_count.text = String(score_count)
                }
                
                // 이미지
                self.game_image.kf.indicatorType = .activity
                self.game_image.kf.setImage(
                    with: URL(string: json["game"]["images"][0].stringValue),
                    options: [
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 400, height: 300))),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(0.3))
                ]) { result in
                    self.evaluate_but.game_image = result.value?.image
                }
                
                // 비디오
                let video_url = json["game"]["videos"][0].stringValue
                if video_url == "영상없음" {
                    self.video_view.isHidden = true
                } else {
                    let playerVars:[String: Any] = [
                        "rel": "0",
                        "iv_load_policy": "3",
                        "playsinline": "1"
                    ]
                    self.game_video.load(withVideoId: String(video_url.suffix(11)), playerVars: playerVars)
                }
                
                self.indicator.stopAnimating()
                self.container_scroll.isHidden = false
            } else {
                self.showalert(message: json["message"].stringValue, can: 0)
            }
        }
    }
    
    func get_score(completionHandler: @escaping (Double) -> Void) {
        Alamofire.request(Api.url + "games/\(game_id!)/score", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 200: completionHandler(json["score"].doubleValue)
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패_score", can: 0)
            }
        }
    }
    
    func get_favor(completionHandler: @escaping (Bool) -> Void) {
        Alamofire.request(Api.url + "games/\(game_id!)/favor", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    switch json["favor"].boolValue {
                    case true: completionHandler(true)
                    default: completionHandler(false)
                    }
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }

    func get_comment(completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "games/\(game_id!)/comments", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                self.comment_arr.removeAll()
                let json = JSON(response.result.value!)
                print(json)
                
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let comments = json["comments"].arrayValue
                    
                    switch comments.count {
                    case 0:
                        self.comment_num.text = "0"
                        
                    default:
                        self.comment_num.text = String(comments.count)
                        
                        for subJson: JSON in comments {
                            let comment = Comment_VO()
                            
                            comment.comment_value = subJson["comment"].stringValue
                            comment.user_id = subJson["user_id"].intValue
                            comment.user_name = subJson["user_name"].stringValue
                            
                            self.comment_arr.append(comment)
                        }
                        
                        completionHandler()
                    }
                    
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패_comment", can: 0)
            }
        }
    }

    func post_comment(_ value: String, completionHandler: @escaping () -> Void) {
        let parameter: [String: Any] = [
            "comment": value
        ]
        
        Alamofire.request(Api.url + "games/\(game_id!)/comments", method: .put, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                switch response.response?.statusCode ?? 0 {
                case 204: completionHandler()
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
            }
            
            response.result.ifFailure {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
    
    func request_comment_up_down(_ comment_id: Int, _ direction: String, _ Whichmehtod: HTTPMethod, completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "games/\(game_id!)/comments/\(comment_id)/\(direction)", method: Whichmehtod, headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 204: completionHandler()
                case ...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            }
            
            response.result.ifFailure {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}


extension Game_info: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment_cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
        let row = comment_arr[indexPath.row]
        
        comment_cell.name.text = row.user_name
        comment_cell.value.text = row.comment_value
        
        comment_cell.like_but.tag = indexPath.row
        comment_cell.dislike_but.tag = indexPath.row
        
        comment_cell.like_but.addTarget(self, action: #selector(up_comment(_:)), for: .touchUpInside)
        comment_cell.dislike_but.addTarget(self, action: #selector(down_comment(_:)), for: .touchUpInside)
        
        return comment_cell
    }
}


extension Game_info: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.comment_textIsempty = true
            self.comment_send.isHidden = true
            UIView.animate(withDuration: Double(0.1), animations: {
                self.comment_right.constant = 30
                self.view.layoutIfNeeded()
            })
            
        } else if comment_textIsempty == true {
            self.comment_textIsempty = false
            UIView.animate(withDuration: Double(0.1), animations: {
                self.comment_right.constant = 65
                self.view.layoutIfNeeded()
            }) { result in
                self.comment_send.isHidden = false
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
