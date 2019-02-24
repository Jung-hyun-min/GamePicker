import UIKit
import SwiftyJSON
import Alamofire

class Post_read: UIViewController {
    // 컨테이너
    @IBOutlet var container_view: UIView!
    @IBOutlet var container_scroll: UIScrollView!
    @IBOutlet var container_stack: UIStackView!
    
    // 스택 element
    @IBOutlet var post_view: UIView!
    @IBOutlet var comment_util: UIView!
    @IBOutlet var comment_table: UITableView!
    
    // post view element
    @IBOutlet var post_title: UILabel!
    @IBOutlet var user_name: UILabel!
    @IBOutlet var post_date: UILabel!
    @IBOutlet var post_recommends: UILabel!
    @IBOutlet var post_comments: UILabel!
    @IBOutlet var post_views: UILabel!
    @IBOutlet var post_value: UILabel!
    @IBOutlet var post_up_but: UIButton!
    @IBOutlet var post_down_but: UIButton!
    @IBOutlet var post_more: UIButton!
    
    // constraint
    @IBOutlet var comment_down: NSLayoutConstraint!
    @IBOutlet var comment_right: NSLayoutConstraint!
    @IBOutlet var comment_left: NSLayoutConstraint!
    @IBOutlet var comment_up: NSLayoutConstraint!
    
    // comment util
    @IBOutlet var comment_util_comments: UILabel!
    
    @IBOutlet var comment_toolbar: UIView!
    @IBOutlet var comment_textview: UITextView!
    @IBOutlet var comment_send: UIButton!
    @IBOutlet var comment_resign: UIButton!
    @IBOutlet var comment_text: UILabel!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    // 게시글 identifier
    var post_id: Int = 0
    var game_title: String = ""
    
    var post_up_num: Int = 0
    var post_down_num: Int = 0
    
    // 게시글 추천 비추천 여부
    var post_Isup: Bool = false
    var post_Isdown: Bool = false
    
    var current_comment_index:Int = -1
    var comment_textIsempty: Bool = true
    let placeholder: String = "\(UserDefaults.standard.string(forKey: data.user.name)!)님의 의견을 적어주세요."
    
    var comment_arr = [Comment_VO]()
    
    var category: String?
    var delegate: IsreloadDataDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comment_toolbar.layer.borderColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1).cgColor
        comment_textview.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        comment_textview.text = placeholder
        comment_textview.textColor = UIColor.lightGray
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = game_title
        
        // 로딩 전까지 hidden
        post_view.isHidden = true
        comment_util.isHidden = true
        
        // 추천 비추천 버튼 경계 색 추가
        post_up_but.layer.borderColor = UIColor(red:0.12, green:0.15, blue:0.17, alpha:1.0).cgColor
        post_down_but.layer.borderColor  = UIColor(red:0.12, green:0.15, blue:0.17, alpha:1.0).cgColor
    
        // post id 판별
        switch post_id {
        case 0: showalert(message: "게시글 읽기 오류", can: 0)
        default:
            self.get_post()
            self.get_comment() {
                self.comment_table.reloadData()
                self.indicator.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Post_write
        param.isEdit = true
        param.edit_id = post_id
        param.edit_title = post_title.text
        param.edit_value = post_value.text
    }
    
    
    @IBAction func write_comment(_ sender: Any) {
        let comment_text = comment_textview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var comment_id: Int {
            if current_comment_index == -1 { return 0 }
            else { return comment_arr[current_comment_index].comment_id! }
        }
        
        post_comment(comment_text, comment_id: comment_id) {
            custom_alert.red_alert(text: "댓글 작성 완료")
            self.get_comment() {
                self.comment_table.reloadData()
                if self.current_comment_index == -1 {
                    DispatchQueue.main.async() { self.scroll_bottom() }
                }
                else { self.current_comment_index = -1 }
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
    
    @IBAction func resign_comment(_ sender: Any) {
        self.comment_textview.resignFirstResponder()
        current_comment_index = -1
    }
    
    @IBAction func post_up(_ sender: Any) {
        self.post_up_but.isEnabled = false
        if post_Isup {
            // 추천 된 상황 delete
            self.post_up_num -= 1
            self.post_up_but.setTitle(String(self.post_up_num), for: .normal)
            self.post_up_but.layer.borderWidth = 1
            self.post_Isup = false
            request_post_up_down("recommend", HTTPMethod.delete) {
                custom_alert.red_alert(text: "추천 취소")
                self.post_up_but.isEnabled = true
            }
            
        } else {
            // 추천 안된 상황 post
            self.post_up_num += 1
            self.post_up_but.setTitle(String(self.post_up_num), for: .normal)
            self.post_up_but.layer.borderWidth = 2
            self.post_Isup = true
            request_post_up_down("recommend", HTTPMethod.post) {
                custom_alert.red_alert(text: "추천 완료")
                self.post_up_but.isEnabled = true
            }
        }
        
    }
    
    @IBAction func post_down(_ sender: Any) {
        self.post_down_but.isEnabled = false
        if post_Isdown {
            // 비추천 된 상황 delete
            self.post_down_num -= 1
            self.post_down_but.setTitle(String(self.post_down_num), for: .normal)
            self.post_down_but.layer.borderWidth = 1
            self.post_Isdown = false
            request_post_up_down("disrecommend", HTTPMethod.delete) {
                custom_alert.red_alert(text: "비추천 취소")
                self.post_down_but.isEnabled = true
            }
        } else {
            // 비추천 안된 상황 post
            self.post_down_num += 1
            self.post_down_but.setTitle(String(self.post_down_num), for: .normal)
            self.post_down_but.layer.borderWidth = 2
            self.post_Isdown = true
            request_post_up_down("disrecommend", HTTPMethod.post) {
                custom_alert.red_alert(text: "비추천 완료")
                self.post_down_but.isEnabled = true
            }
        }
    }
    
    @IBAction func more(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        let update = UIAlertAction(title: "수정", style: .default) {_ in
            self.put_post()
        }
        let delete = UIAlertAction(title: "삭제", style: .default) {_ in
            self.delete_post()
        }
        
        alert.addAction(cancel)
        alert.addAction(update)
        alert.addAction(delete)
        
        self.present(alert,animated: true)
    }
    
    
    @objc func up_comment(_ sender: UIButton) {
        print("\(sender.tag) like")
    }
    
    @objc func down_comment(_ sender: UIButton) {
        print("\(sender.tag) dislike")
    }
    
    @objc func recomment_comment(_ sender: UIButton) {
        self.current_comment_index = sender.tag
        self.comment_text.text = self.comment_arr[self.current_comment_index].comment_value
        DispatchQueue.main.async {
            self.comment_textview.becomeFirstResponder()
        }
    }
    
    
    /* 키보드 hide show functions */
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if container_view.frame.size.height-(comment_toolbar.frame.origin.y+comment_toolbar.frame.size.height) == 0 {
            let endFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let kh = endFrame.cgRectValue.height - (tabBarController?.tabBar.frame.size.height)!
            
            self.comment_resign.isHidden = false
            UIView.animate(withDuration: Double(0.35), animations: {
                self.comment_down.constant = kh
                self.comment_left.constant = 65
            
                if self.current_comment_index != -1 {
                    self.comment_up.constant = 45
                    self.comment_text.isHidden = false
                }
                
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
            self.comment_text.isHidden = true
            UIView.animate(withDuration: Double(0.35), animations: {
                self.comment_down.constant = 0
                self.comment_left.constant = 30
                self.comment_up.constant = 8
                
                self.view.layoutIfNeeded()
            })
                
        }
    }
    
    
    func scroll_bottom() {
        if self.container_scroll.contentSize.height > self.container_scroll.bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: self.container_scroll.contentSize.height - self.container_scroll.bounds.size.height)
            self.container_scroll.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    
    /* request functions */
    func get_post() {
        Alamofire.request(Api.url + "posts/\(post_id)", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                
                if response.response?.statusCode == 200 {
                    let user_id = UserDefaults.standard.integer(forKey: data.user.id)
                    
                    switch json["post"]["user_id"].intValue {
                    case user_id: self.post_more.isHidden = false
                    default: self.post_more.isHidden = true
                    }
                    
                    if self.category == "anonymous" {
                        self.user_name.text = "익명"
                    } else {
                        self.user_name.text = json["post"]["name"].stringValue
                    }
                    
                    self.post_title.text      = json["post"]["title"].stringValue
                    self.post_value.text      = json["post"]["value"].stringValue
                    self.post_recommends.text = json["post"]["recommends"].stringValue
                    self.post_views.text      = json["post"]["views"].stringValue
                    
                    // 작성 시간
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    self.post_date.text = dateFormatter.date(from: json["post"]["created_at"].stringValue)?.relativeTime
                    
                    self.post_up_num = json["post"]["recommends"].intValue
                    self.post_down_num = json["post"]["disrecommends"].intValue
                    self.post_up_but.setTitle(String(self.post_up_num), for: .normal)
                    self.post_down_but.setTitle(String(self.post_down_num), for: .normal)

                    if json["post"]["recommended"].intValue == 1 {
                        self.post_Isup = true
                        self.post_up_but.layer.borderWidth = 2
                        self.post_up_but.layer.borderColor = UIColor(red:0.12, green:0.15, blue:0.17, alpha:1.0).cgColor
                    }
                    
                    if json["post"]["disrecommended"].intValue == 1 {
                        self.post_Isdown = true
                        self.post_down_but.layer.borderWidth = 2
                        self.post_down_but.layer.borderColor = UIColor(red:0.12, green:0.15, blue:0.17, alpha:1.0).cgColor
                    }
                    self.post_view.isHidden = false
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    print(response.response?.statusCode ?? 0)
                    self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
    
    func put_post() {
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    func delete_post() {
        Alamofire.request(Api.url + "posts/\(post_id)", method: .delete, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    custom_alert.red_alert(text: "게시글 삭제 완료")
                    self.delegate?.reload()
                    self.navigationController?.popViewController(animated: true)
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    print(response.response?.statusCode ?? 0)
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                self.showalert(message: "네트워크 연결 오류", can: 0)
            }
        }
        
    }
    
    func get_comment(completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "posts/\(post_id)/comments", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                self.comment_arr.removeAll()
                if response.response?.statusCode == 200 {
                    let comments = json["comments"].arrayValue
                    switch comments.count {
                    case 0:
                        self.post_comments.text = "0"
                        self.comment_util_comments.text = "0"
                        
                    default:
                        self.post_comments.text = String(comments.count)
                        self.comment_util_comments.text = String(comments.count)
                        
                        for subjson: JSON in comments {
                            let comment = Comment_VO()
                            
                            comment.comment_id    = subjson["id"].intValue
                            comment.comment_value = subjson["value"].stringValue
                            comment.recommends    = subjson["recommends"].intValue
                            comment.disrecommends = subjson["disrecommends"].intValue
                            comment.user_name     = subjson["name"].stringValue
                            comment.user_id       = subjson["user_id"].intValue
                            comment.created_at    = subjson["created_at"].stringValue
                        
                            let re_comments = subjson["comments"].arrayValue
                            for subusbjson: JSON in re_comments {
                                let re_comment = Comment_VO()
                                
                                re_comment.comment_id    = subusbjson["id"].intValue
                                re_comment.comment_value = subusbjson["value"].stringValue
                                re_comment.recommends    = subusbjson["recommends"].intValue
                                re_comment.disrecommends = subusbjson["disrecommends"].intValue
                                re_comment.user_name     = subusbjson["name"].stringValue
                                re_comment.user_id       = subusbjson["user_id"].intValue
                                re_comment.created_at    = subusbjson["created_at"].stringValue
                                
                                comment.re_comment_arr.append(re_comment)
                            }
                            
                            self.comment_arr.append(comment)
                        }

                    }
                    
                    completionHandler()
                    
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
    
    func post_comment(_ comment_value: String, comment_id: Int, completionHandler: @escaping () -> Void) {
        var parameter: [String: Any] = [
            "value": comment_value
        ]
        
        if comment_id > 0 {
            parameter.updateValue(comment_id, forKey: "parent_id")
        }
        
        
        Alamofire.request(Api.url + "posts/\(post_id)/comments", method: .post, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            guard response.result.isSuccess else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
                return
            }
            let json = JSON(response.result.value!)
            switch response.response?.statusCode ?? 0 {
            case 204: completionHandler()
            case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
            default: self.showalert(message: "서버 오류", can: 0)
            }
        }
    }
    
    func request_post_up_down(_ direction: String, _ Whichmehtod: HTTPMethod, completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "posts/\(post_id)/\(direction)", method: Whichmehtod, headers: Api.authorization).responseJSON { (response) in
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
    
    func request_comment_up_down(_ direction: String, _ Whichmehtod: HTTPMethod, completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "posts/\(post_id)/\(direction)", method: Whichmehtod, headers: Api.authorization).responseJSON { (response) in
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


extension Post_read: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return comment_arr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment_arr[section].re_comment_arr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let comment_cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
            let row = self.comment_arr[indexPath.section]
            
            if category == "anonymous" {
                comment_cell.name.text = "익명"
            } else {
                comment_cell.name.text = row.user_name
            }
            
            comment_cell.value.text = row.comment_value
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            comment_cell.created_at.text = dateFormatter.date(from: row.created_at!)?.relativeTime
            
            comment_cell.score.text = "\(row.recommends! - row.disrecommends!)"
            
            comment_cell.recomment_but.tag = indexPath.section
            comment_cell.like_but.tag = row.comment_id!
            comment_cell.dislike_but.tag = row.comment_id!
            
            comment_cell.recomment_but.addTarget(self, action: #selector(recomment_comment(_:)), for: .touchUpInside)
            comment_cell.like_but.addTarget(self, action: #selector(up_comment(_:)), for: .touchUpInside)
            comment_cell.dislike_but.addTarget(self, action: #selector(down_comment(_:)), for: .touchUpInside)
            
            return comment_cell
        } else {
            let re_comment_cell = tableView.dequeueReusableCell(withIdentifier: "recomment", for: indexPath) as! Re_comment_cell
            let row = self.comment_arr[indexPath.section].re_comment_arr[indexPath.row - 1]
            
            re_comment_cell.name.text = row.user_name
            re_comment_cell.value.text = row.comment_value
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            re_comment_cell.created_at.text = dateFormatter.date(from: row.created_at!)?.relativeTime
            
            re_comment_cell.score.text = "\(row.recommends! - row.disrecommends!)"
            
            re_comment_cell.like_but.addTarget(self, action: #selector(up_comment(_:)), for: .touchUpInside)
            re_comment_cell.dislike_but.addTarget(self, action: #selector(down_comment(_:)), for: .touchUpInside)
            
            return re_comment_cell
        }
        
        
    }
}


extension Post_read: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.comment_textIsempty = true
            self.comment_send.isHidden = true
            UIView.animate(withDuration: Double(0.2), animations: {
                self.comment_right.constant = 30
                self.view.layoutIfNeeded()
            })
            
        } else if comment_textIsempty == true {
            self.comment_textIsempty = false
            UIView.animate(withDuration: Double(0.2), animations: {
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
