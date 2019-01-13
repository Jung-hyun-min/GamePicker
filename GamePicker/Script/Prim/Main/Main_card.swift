import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Main_card: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var stack: UIStackView!
    
    @IBOutlet var notify: UIView!
    @IBOutlet var div: UIView!
    @IBOutlet var msg_view: UIView!
    @IBOutlet var cancel: NSLayoutConstraint!
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var all_card_height: NSLayoutConstraint!

    let screen_width: CGFloat = UIScreen.main.bounds.width
    
    lazy var game : [Main_VO] = {
        var datalist = [Main_VO]()
        return datalist
    }()
    
    lazy var refreshControl : UIRefreshControl = { // 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl) { // 새로고침 실행 함수
        game.removeAll()
        get_games()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigation_icon()
        if Connectivity.isConnectedToInternet {
            get_games()
        } else {
            showalert(message: "서버 응답 없음", can: 0)
        }
        self.stack.addSubview(self.refreshControl)
        notify.layer.borderColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0).cgColor
        all_card_height.constant = 4 * (screen_width * 415/375 + 26)
    }
    
    @IBAction func close_msg(_ sender: Any) {
        div.isHidden = true
        msg_view.isHidden = true
        cancel.constant = 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screen_width*415/375 + 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game_cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! Main_cell
        var str_temp : String = ""
        game_cell.card_height.constant = screen_width*415/375
        game_cell.card_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.rate_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.rate_view.layer.cornerRadius = (screen_width-36)/14
        let row = self.game[indexPath.row]
        
        game_cell.game_name.text = row.title // 게임 이름
        
        if row.rate_count == 0 { // 게임 평점
            game_cell.rate_view.isHidden = true
            game_cell.rating_star.isHidden = true
            game_cell.game_rating2.text = "평가없슴"
            game_cell.game_rating_num.text = ""
        } else {
            game_cell.rate_view.isHidden = false
            game_cell.rating_star.isHidden = false
            game_cell.game_rating1.text = "\(round(Double(row.rate ?? -1 * 10))/10)"
            game_cell.game_rating2.text = "\(round(Double(row.rate ?? -1 * 10))/10)"
            game_cell.game_rating_num.text = "(\(row.rate_count ?? -1))"
        }
        
        for platforms in row.platforms ?? [""] { // 게임 플랫폼
            str_temp.append(contentsOf: platforms)
            str_temp.append(contentsOf: ", ")
        }
        game_cell.game_platform.text = String(str_temp.prefix(str_temp.count - 2))
        
        game_cell.game_image.kf.indicatorType = .activity // 게임 이미지
        game_cell.game_image.kf.setImage(
            with: URL(string: row.images!),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 400, height: 300))),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ])
        game_cell.more_but.tag = row.id ?? 0
        game_cell.more_but.addTarget(self, action: #selector(more(_:)), for: .touchUpInside)

        let guesture_1 = UITapGestureRecognizer(target: self, action: #selector(favorite))
        let guesture_2 = UITapGestureRecognizer(target: self, action: #selector(score))
        let guesture_3 = UITapGestureRecognizer(target: self, action: #selector(commuity))

        game_cell.favorite.addGestureRecognizer(guesture_1)
        game_cell.score.addGestureRecognizer(guesture_2)
        game_cell.commuity.addGestureRecognizer(guesture_3)
        
        return game_cell
    }
    
    @objc func favorite() {
        custom_alert.red_alert(text: "찜했습니다.")
    }
    @objc func score() {
        
    }
    @objc func commuity() {
        print("commuity")
    }
    
    @objc func more(_ sender : UIButton) {
        self.performSegue(withIdentifier: "game_info", sender: sender.tag)
    }
    
    func get_games() {
        Alamofire.request(Api.url + "games?limit=4&sort=random").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                for (_, subJson):(String, JSON) in json["games"] {
                    let main = Main_VO()
                    main.id         = subJson["id"].intValue
                    main.title      = subJson["title"].stringValue
                    main.images     = subJson["images"][0].stringValue
                    main.rate       = subJson["score"].intValue
                    main.rate_count = subJson["score_count"].intValue
                    main.platforms = subJson["platforms"].arrayObject as? [String]
                    self.game.append(main)
                }
            } else {
                self.showalert(message: "서버 응답 오류", can: 0)
            }
            
            self.table.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.id = sender as! Int
    }
    
}
