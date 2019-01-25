import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import youtube_ios_player_helper

class Game_info: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var view_1: UIView!
    @IBOutlet var view_2: UIView!
    @IBOutlet var const_1: NSLayoutConstraint!
    @IBOutlet var const_2: NSLayoutConstraint!
    
    @IBOutlet var community: UIStackView!
    @IBOutlet var score: UIStackView!
    @IBOutlet var favorite: UIStackView!
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rate: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var platform: UILabel!
    @IBOutlet var developer: UILabel!
    @IBOutlet var publisher: UILabel!
    
    @IBOutlet var video: YTPlayerView!
    @IBOutlet var relation: UILabel!
    @IBOutlet var const_video: NSLayoutConstraint!
    
    @IBOutlet var summary: UILabel!
    @IBOutlet var comment_num: UILabel!
    
    @IBOutlet var comment_table: UITableView!

    var game_id : Int = 0
    
    lazy var comment : [Comment_VO] = {
        var datalist = [Comment_VO]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comment.removeAll()
        
        get_check_favor()
        get_game()
        //get_reviews()
        
        let gesture_1 = UITapGestureRecognizer(target: self, action: #selector(favorite_a))
        let gesture_2 = UITapGestureRecognizer(target: self, action: #selector(score_a))
        let gesture_3 = UITapGestureRecognizer(target: self, action: #selector(community_a))
        
        favorite.addGestureRecognizer(gesture_1)
        score.addGestureRecognizer(gesture_2)
        community.addGestureRecognizer(gesture_3)
    }
    
    @objc func favorite_a() {
        custom_alert.red_alert(text: "찜했습니다.")
    }
    
    @objc func score_a() {
        custom_alert.score_alert(id: game_id, title: name.text!, image: image!.image ?? UIImage(named: "picture")!)
    }
    
    @objc func community_a() {
        performSegue(withIdentifier: "posts", sender: self)
    }
    
    // 게임 상세보기 뷰 prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Post
        param.game_id = game_id
        param.game_title = name.text!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment_cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
        let row = comment[indexPath.row]
        
        comment_cell.value.text = row.comment_value
        comment_cell.name.text = row.user_name
        comment_cell.date.text = row.updated_at
        
        return comment_cell
    }
    
    @IBAction func close_1(_ sender: Any) {
        view_1.isHidden = true
        const_1.constant = 10
    }
    @IBAction func close_2(_ sender: Any) {
        view_2.isHidden = true
        const_2.constant = 10
    }
    
    func get_game() {
        Alamofire.request(Api.url + "games/\(game_id)").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    self.name.text      = json["game"]["title"].stringValue
                    self.age.text       = json["game"]["age_rate"].stringValue
                    self.developer.text = json["game"]["developer"].stringValue
                    self.publisher.text = json["game"]["publisher"].stringValue
                    self.summary.text   = json["game"]["summary"].stringValue
                    
                    // 평점
                    let score = json["game"]["score"].floatValue
                    let score_count = json["game"]["score_count"].intValue
                    if score_count == 0 {
                        self.rate.text = "아직 평가되지 않았습니다."
                    } else {
                        self.rate.text = "평점: \(round(score*10)/10) (\(score_count) 명)"
                    }
                    
                    // 이미지
                    self.image.kf.indicatorType = .activity
                    self.image.kf.setImage(
                        with: URL(string: json["game"]["images"][0].stringValue),
                        options: [
                            .processor(DownsamplingImageProcessor(size: CGSize(width: 400, height: 300))),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(0.3))
                            ])
                    
                    // 비디오
                    let video_url = json["game"]["videos"][0].stringValue
                    if video_url == "영상없음" {
                        self.video.isHidden = true
                        self.relation.isHidden = true
                        self.const_video.constant = 10
                    } else {
                        self.const_video.constant = UIScreen.main.bounds.width/16*9 + 59
                        let playerVars:[String: Any] = [
                            "rel": "0",
                            "iv_load_policy" : "3",
                            "playsinline" : "1"
                        ]
                        self.video.load(withVideoId: String(video_url.suffix(11)), playerVars: playerVars)
                    }
                } else {
                    self.showalert(message: json["message"].stringValue, can: 0)
                }
            } else {
                self.showalert(message: "게임 데이터 조회 네트워크 오류", can: 0)
            }
        }
    }
    
    func get_reviews() {
        Alamofire.request(Api.url + "games/\(game_id)/reviews").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                for (_,subJson):(String, JSON) in json["data"]["comments"] {
                    let id = subJson["id"].intValue
                    let value = subJson["value"].stringValue
                    let update_date = subJson["update_date"].stringValue
                    let name = subJson["name"].stringValue
                    
                    let comment = Comment_VO()
                    
                    comment.comment_id = id
                    comment.comment_value = value
                    comment.updated_at = update_date
                    comment.user_name = name
                    
                    self.comment.append(comment)
                }
            } else {
                self.showalert(message: "코멘트 데이터 조회 네트워크(time) 오류", can: 0)
            }
        }
    }
    
    func get_check_favor() {
        let header: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: data.user.token) ?? ""
        ]
        
        Alamofire.request(Api.url + "games/\(game_id)/favor",headers: header).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    if json["favor"].boolValue {
                        print("a")
                    } else {
                        print("b")
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

}
