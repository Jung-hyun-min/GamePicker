import UIKit
import SwiftyJSON
import SwiftMessages
import Alamofire
import Kingfisher

class Profile: UIViewController {
    @IBOutlet var post_table: IntrinsicTableView!
    
    @IBOutlet var firtsh_height: NSLayoutConstraint!
    @IBOutlet var container_scroll: UIScrollView!
    @IBOutlet var close_view: UIView! // 알림 메세지
    
    @IBOutlet var profile_image: UIImageView! // 프로필
    @IBOutlet var background_but: UIButton! // 백그라운드
    @IBOutlet var user_name: UILabel!   // 이름
    @IBOutlet var user_intro: UILabel!  // 소개
    
    @IBOutlet var premium: UIButton! // 프리미엄
    @IBOutlet var logout: UIButton! // 로그아웃 버튼
    
    @IBOutlet var analyze1: UIView!
    @IBOutlet var analyze2: UIView!
    
    @IBOutlet var premium_img: UIView!
    @IBOutlet var premium_txt: UILabel!
    
    @IBOutlet var favor_count: UILabel!
    @IBOutlet var score_count: UILabel!
    
    
    var post_arr = [Post_VO]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height = UIScreen.main.bounds.height - (tabBarController?.tabBar.frame.size.height)! - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.height
        firtsh_height.constant = height
        
        profile_image.layer.cornerRadius  = UIScreen.main.bounds.width/8
        profile_image.layer.borderColor   = UIColor.white.cgColor
        
        background_but.imageView?.contentMode = .scaleAspectFill
        
        premium.layer.borderColor = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        logout.layer.borderColor  = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profile_chk()
        get_user_data()
        get_user_post()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "favor":
            let param = segue.destination as! User_game
            param.which = "favor"
            
        case "score":
            let param = segue.destination as! User_game
            param.which = "score"
            
        default: break
        }
    }
    
    
    @IBAction func message_close(_ sender: Any) {
        close_view.isHidden = true
    }
    
    @IBAction func edit(_ sender: Any) {
        let alert = UIAlertController(title: "프로필", message: "수정 하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) { UIAlertAction in
            self.performSegue(withIdentifier: "edit", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let view: Center_logout = try! SwiftMessages.viewFromNib()
        view.logoutAction = {
            SwiftMessages.hide()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.dimMode = .color(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7), interactive: true)
        
        SwiftMessages.show(config: config, view: view)
    }
    
    @IBAction func premium(_ sender: Any) {
        premium.isHidden = true
        premium_img.isHidden = false
        premium_txt.isHidden = false
    }
 
    @IBAction func look_mypost(_ sender: Any) {
    }
    
    
    func profile_chk() {
        let User_data = UserDefaults.standard
        
        // 이름
        if let name = User_data.string(forKey: data.user.name) {
            user_name.text = name
        }
        
        // 자기소개
        if let introduce = User_data.string(forKey: data.user.introduce) {
            if !introduce.isEmpty { user_intro.text = introduce }
            else { user_intro.text = "자기소개를 입력하세요." }
        } else { user_intro.text = "자기소개를 입력하세요." }
        
        // 프로필 사진
        if let front_image = User_data.string(forKey: data.user.profile) {
            profile_image.kf.indicatorType = .activity
            profile_image.kf.setImage(
                with: URL(string: "http://" + front_image),
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
            ])
            
        } else {
            profile_image.image = UIImage(named: "ic_profile")
        }
        
    }
    
    
    func get_user_data() {
        guard let user_id = UserDefaults.standard.string(forKey: data.user.id) else { return }
        
        Alamofire.request(Api.url + "users/\(user_id)/games/score", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let arr = json["scores"].arrayValue
                    if self.score_count.text! < String(arr.count) {
                        self.score_count.pushTransition(direction: .fromTop)
                    } else if self.score_count.text! > String(arr.count) {
                        self.score_count.pushTransition(direction: .fromBottom)
                    }
                    self.score_count.text = String(arr.count)
                    
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
        
        Alamofire.request(Api.url + "users/\(user_id)/games/favor", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let arr = json["favors"].arrayValue
                    if self.favor_count.text != String(arr.count) {
                        self.favor_count.pushTransition(direction: .fromTop)
                    } else if self.favor_count.text! > String(arr.count) {
                        self.favor_count.pushTransition(direction: .fromBottom)
                    }
                    self.favor_count.text = String(arr.count)
                    
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
        
        
    }
    
    func get_user_post() {
        let user_id = UserDefaults.standard.integer(forKey: data.user.id)
        Alamofire.request(Api.url + "users/\(user_id)/posts?limit=3", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 200: print(json)
                
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
                    
                        self.post_arr.append(post)
                    }
                
                    self.post_table.reloadData()
                    
                    
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}

/*
extension Profile: UITableViewDelegate,UITableViewDataSource {
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
        
        if row.post_isMine! {
            post_cell.user_name.font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        post_cell.post_created_at.text = dateFormatter.date(from: row.post_created_at!)?.relativeTime
        
        if row.game_title != nil {
            post_cell.game_title.isHidden = false
            post_cell.game_title.text = row.game_title
        }
        
        post_cell.user_name.text = row.user_name
        
        
        return post_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let child = self.instanceMainVC(name: "post_read") as? Post_read
        child!.post_id = post_arr[indexPath.row].post_id!
        child?.category = category
        child?.game_title = post_arr[indexPath.row].game_title ?? category!
        self.navigationController?.pushViewController(child!, animated: true)
    }
}
*/
