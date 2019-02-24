import UIKit
import Alamofire
import SwiftyJSON


class Post_list: UIViewController,IsreloadDataDelegate {
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var post_empty: [UILabel]!
    @IBOutlet var post_table: UITableView!
    @IBOutlet var post_game_title: UILabel!
    
    
    var category: String?
    var game_title: String?
    var game_id: Int?
    var isGame: Bool?
    
    
    var post_arr = [Post_VO]()
    
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        self.post_table.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.post_table.refreshControl = refreshControl
        self.post_game_title.text = game_title
        self.navigationController?.navigationBar.topItem?.title = ""
        get_post()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "write":
            let param = segue.destination as! Post_write
            param.isEdit = false
            param.game_id = game_id ?? 0
            param.delegate = self
            param.category = category
            
        case "edit":
            let param = segue.destination as! Post_write
            let index = sender as! Int
            param.isEdit = true
            param.edit_id = post_arr[index].post_id!
            param.edit_title = post_arr[index].post_title!
            param.edit_value = post_arr[index].post_value!
            param.delegate = self
            param.category = category
            
        case "read":
            let param = segue.destination as! Post_read
            let index = sender as! Int
            param.delegate = self
            param.game_title = post_arr[index].game_title ?? category!
            param.post_id = post_arr[index].post_id!
            param.category = category
            
        default: break
        }
    }
    
    
    @IBAction func post_search(_ sender: Any) {
        self.showalert(message: "준비중인 기능입니다.", can: 1)
    }
    
    @IBAction func post_write(_ sender: Any) {
        performSegue(withIdentifier: "write", sender: self)
    }
    
    
    @objc func reload() {
        get_post()
    }
    
    @objc func more(_ sender: UIButton) {
        let index = sender.tag
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        let update = UIAlertAction(title: "수정", style: .default) {_ in
            self.put_post(index)
        }
        let delete = UIAlertAction(title: "삭제", style: .default) {_ in
            self.delete_post(self.post_arr[index].post_id!)
        }
        
        alert.addAction(cancel)
        alert.addAction(update)
        alert.addAction(delete)
        
        self.present(alert,animated: true)
    }
    
    
    func get_post() {
        var url: String {
            if isGame ?? false {
                return Api.url + "posts?game_id=\(game_id ?? 0)&category=\(category!)"
            } else {
                return Api.url + "posts?&category=\(category!)"
            }
        }
        
        Alamofire.request(url, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                self.post_arr.removeAll()
                let json = JSON(response.result.value!)
                 
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let posts = json["posts"].arrayValue
                    
                    guard posts.count != 0 else {
                        self.indicator.stopAnimating()
                        self.post_table.isHidden = true
                        self.post_empty[0].isHidden = false
                        self.post_empty[1].isHidden = false
                        return
                    }
                    
                    let user_id = UserDefaults.standard.integer(forKey: data.user.id)
                    
                    for subjson: JSON in posts {
                        let post = Post_VO()
                        
                        post.user_name = subjson["name"].stringValue
                         
                        switch subjson["user_id"].intValue {
                        case user_id: post.post_isMine = true
                        default: post.post_isMine = false
                        }
                        
                        post.game_id = subjson["game_id"].intValue
                        post.game_title = subjson["game_title"].stringValue
                        
                        post.post_id = subjson["id"].intValue
                        post.post_title = subjson["title"].stringValue
                        post.post_value = subjson["value"].stringValue
                        post.post_views = subjson["views"].intValue
                        post.post_created_at = subjson["created_at"].stringValue
                        post.post_recommends = subjson["recommends"].intValue
                        post.post_disrecommends = subjson["disrecommends"].intValue
                        post.post_comments = subjson["comment_count"].intValue
                        
                        self.post_arr.append(post)
                    }
                    
                    self.refreshControl.endRefreshing()
                    self.indicator.stopAnimating()
                    self.post_table.reloadData()
                    self.post_table.isHidden = false
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
    
    func put_post(_ index: Int) {
        performSegue(withIdentifier: "edit", sender: index)
    }

    func delete_post(_ post_id: Int) {
        Alamofire.request(Api.url + "posts/\(post_id)", method: .delete, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    custom_alert.red_alert(text: "게시글 삭제 완료")
                    self.reload()
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
}


extension Post_list: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post_cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as! Post_cell
        let row = self.post_arr[indexPath.row]
        
        post_cell.post_title.text = row.post_title
        
        post_cell.post_recommends.text = String(row.post_recommends!)
        post_cell.post_comments.text = "["+String(row.post_comments!)+"]"
        post_cell.post_views.text = String(row.post_views!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        post_cell.post_created_at.text = dateFormatter.date(from: row.post_created_at!)?.relativeTime

        if row.post_isMine! {
            post_cell.post_option.isHidden = false
            post_cell.post_option.tag = indexPath.row
            post_cell.post_option.addTarget(self, action: #selector(more(_:)), for: .touchUpInside)
        } else {
            post_cell.post_option.isHidden = true
        }
        
        if category == "games" && !(isGame ?? false) {
            post_cell.game_title.isHidden = false
            post_cell.game_title.text = row.game_title
        }
        
        if category == "anonymous" {
            post_cell.user_name.text = "익명"
        } else {
            post_cell.user_name.text = row.user_name
        }
        
        return post_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "read", sender: indexPath.row)
    }
}


protocol IsreloadDataDelegate {
    func reload()
}
