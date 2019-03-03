import UIKit
import Alamofire
import SwiftyJSON

class Community: UIViewController {
    @IBOutlet var container_scroll: UIScrollView!
    
    @IBOutlet var community_table: IntrinsicTableView!
    @IBOutlet var message_view: UIView!
    
    @IBOutlet var message_notify: UIView!
    @IBOutlet var message_main: UILabel!
    @IBOutlet var message_sub: UILabel!
    @IBOutlet var message_yes: UIButton!
    @IBOutlet var message_no: UIButton!
    @IBOutlet var message_close: UIButton!
    
    
    var community_arr = [Community_VO]()
    
    let message_functions = User_message()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(community_refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        add_community()
        navigation_icon()
        
        container_scroll.refreshControl = refreshControl
        message_notify.layer.borderColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0).cgColor
        
        message_functions.message_view = self.message_view
        message_functions.main_title = self.message_main
        message_functions.sub_title = self.message_sub
        
        message_no.addTarget(message_functions, action: #selector(message_functions.response_no), for: .touchUpInside)
        message_yes.addTarget(message_functions, action: #selector(message_functions.response_yes), for: .touchUpInside)
        message_close.addTarget(message_functions, action: #selector(message_functions.hide_view), for: .touchUpInside)
        
        message_functions.community_message()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as! Int
        let param = segue.destination as! Post_list
        param.category = community_arr[index].category
        param.game_title = community_arr[index].title
    }
    
    
    func add_community() {
        let community1 = Community_VO()
        let community2 = Community_VO()
        let community3 = Community_VO()
        
        community1.category = "free"
        community2.category = "anonymous"
        community3.category = "games"
        
        community1.title = "자유 게시판"
        community2.title = "익명 게시판"
        community3.title = "최신 게시글"
        
        community_arr.append(community1)
        community_arr.append(community2)
        community_arr.append(community3)
        
        post_process()
    }
    
    func post_process() {
        let post_group = DispatchGroup()
        
        for i in 0..<community_arr.count {
            post_group.enter()
            
            self.community_arr[i].post_arr.removeAll()
            
            get_post(community_arr[i].category!, index: i) {
                post_group.leave()
            }
        }

        post_group.notify(queue: .main) {
            self.community_table.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    @objc func community_refresh() {
        post_process()
    }
    
    @objc func more(_ sender: UIButton?) {
        let index = sender?.tag
        performSegue(withIdentifier: "read", sender: index)
    }
    
    
    func get_post(_ community_category: String, index: Int, completionHandler : @escaping () -> Void) {
        Alamofire.request(Api.url + "posts?category=\(community_category)&limit=3", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let posts = json["posts"].arrayValue
                    let user_id = UserDefaults.standard.integer(forKey: data.user.id)
                    
                    for subjson: JSON in posts {
                        let post = Post_VO()
                        
                        switch subjson["user_id"].intValue {
                        case user_id: post.post_isMine = true
                        default: post.post_isMine = false
                        }
                        
                        post.user_name  = subjson["name"].stringValue
                        post.game_id    = subjson["game_id"].intValue
                        post.game_title = subjson["game_title"].stringValue
                        
                        post.post_id    = subjson["id"].intValue
                        post.post_title = subjson["title"].stringValue
                        post.post_value = subjson["value"].stringValue
                        post.post_views = subjson["views"].intValue
                        post.post_created_at = subjson["created_at"].stringValue
                        post.post_recommends = subjson["recommends"].intValue
                        post.post_disrecommends = subjson["disrecommends"].intValue
                        post.post_comments = subjson["comment_count"].intValue
                        
                        self.community_arr[index].post_arr.append(post)
                    }
                    completionHandler()
                default: break
                }
                
            }
        }
    }
}


extension Community: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return community_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let community_cell = tableView.dequeueReusableCell(withIdentifier: "community", for: indexPath) as! Community_cell
        let row = community_arr[indexPath.row]
        
        community_cell.parent = self
        
        community_cell.community_title.text = row.title
        community_cell.category = row.category
        
        community_cell.post_arr.removeAll()
        community_cell.post_arr = row.post_arr
        
        community_cell.more.tag = indexPath.row
        community_cell.more.addTarget(self, action: #selector(more(_:)), for: .touchUpInside)
        
        community_cell.reload()
        
        return community_cell
    }
}
