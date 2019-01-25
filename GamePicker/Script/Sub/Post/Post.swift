import UIKit
import Alamofire
import SwiftyJSON

class Post: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var table: UITableView!

    var game_id : Int = 0
    var game_title : String = ""
    
    lazy var post_arr : [Post_VO] = {
        var datalist = [Post_VO]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.addSubview(self.refreshControl)
        
        switch game_id {
        case  0:  self.navigationItem.title = "자유 게시판"
        default: self.navigationItem.title = game_title
        }
        
        get_posts()
    }
    
    // 스와이프 리프레시
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl) {
        refresh()
    }
    
    @objc func refresh() {
        post_arr.removeAll()
        self.get_posts()
    }
    
    /* 테이블 뷰 델리게이트 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell") as! Post_cell
        let row = self.post_arr[indexPath.row]
    
        cell.title?.text = row.title
        cell.name?.text = row.name
        cell.recommend?.text = "\(row.recommends!)"
        cell.comment?.text = "\(row.comment_count!)"
        cell.view?.text = "\(row.views!)"
        
        cell.update?.text = row.updated_at
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.post_arr[indexPath.row]
        self.performSegue(withIdentifier: "read", sender: row.id ?? 0)
    }
    
    func get_posts() {
        Alamofire.request(Api.url + "posts?game_id=\(game_id)").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let posts = json["posts"].arrayValue
                if posts.count == 0 {
                    // 게시글이 없음
                    self.table.isHidden = true
                } else {
                    // 게시글이 있음
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    for subJson: JSON in posts {
                        let post = Post_VO()
                        post.id            = subJson["id"].intValue
                        post.user_id       = subJson["user_id"].intValue
                        post.game_id       = subJson["game_id"].intValue
                        post.game_title    = subJson["game_title"].intValue
                        post.title         = subJson["title"].stringValue
                        post.name          = subJson["name"].stringValue
                        post.content       = subJson["content"].stringValue
                        post.views         = subJson["views"].intValue
                        post.category      = subJson["category"].stringValue
                        post.recommends    = subJson["recommends"].intValue
                        post.recommends    = subJson["disrecommends"].intValue
                        post.comment_count = subJson["comment_count"].intValue
                        
                        let str = subJson["updated_at"].stringValue
                        let date = dateFormatter.date(from: String(str.prefix(19)))
                        post.updated_at = date?.relativeTime
                        
                        self.post_arr.append(post)
                    }
                    self.table.reloadData()
                }

                self.refreshControl.endRefreshing()
            } else {
                self.showalert(message: "서버 응답 없음", can: 0)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "read" {
            let param = segue.destination as! Post_read
            param.post_id = sender as! Int
        } else {
            let param = segue.destination as! Post_write
            param.game_id = game_id
        }
    }

}
