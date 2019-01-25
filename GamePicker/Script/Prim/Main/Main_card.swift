import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Main_card: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var stack: UIStackView!
    
    @IBOutlet var notify: UIView!
    @IBOutlet var div: UIView!
    @IBOutlet var msg_view: UIView!
    @IBOutlet var cancel: NSLayoutConstraint!
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var all_card_height: NSLayoutConstraint!

    @IBOutlet var load_indicator: UIActivityIndicatorView!
    
    let screen_width: CGFloat = UIScreen.main.bounds.width
    
    // 게임 클래스 오브젝트 배열
    lazy var game : [Main_VO] = {
        var datalist = [Main_VO]()
        return datalist
    }()
    
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        return refreshControl
    }()
    
    @objc func refresh() {
        game.removeAll()
        get_games()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 스크롤 뷰 숨기고 인디케이터 에니메이션 시작
        scroll.isHidden = true
        
        // 리프레쉬 컨트롤 추가
        scroll.addSubview(refreshControl)
        
        // 네비게이션 아이콘 추가
        navigation_icon()
    
        notify.layer.borderColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0).cgColor
        
        // 카드뷰 높이 설정 2019-1-22 변경
        //all_card_height.constant = 4 * (screen_width * 415/375 + 26)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 어플 처음 출시 하면 튜토리얼
        if UserDefaults.standard.bool(forKey: data.isFirst) == true {
            let vc = self.instanceMainVC(name: "select")
            self.present(vc!, animated: true)
        }
        
        // 자동로그인 체크
        if UserDefaults.standard.bool(forKey: data.isLogin) == false {
            // 자동 로그인 X
            let vc = self.instanceMainVC(name: "select")
            self.present(vc!, animated: true)
        } else {
            // 인터넷 연결 확인
            if Connectivity.isConnectedToInternet {
                // 네트워크 연결 O
                get_games()
            } else {
                // 네트워크 연결 X
                showalert(message: "서버 응답 없음", can: 0)
            }
        }
    }
    
    @IBAction func close_msg(_ sender: Any) {
        div.isHidden = true
        msg_view.isHidden = true
        cancel.constant = 30
    }
    
    /* 텍스트 필드 delegate 추가 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game_cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! Main_cell
        var str_temp : String = ""
        game_cell.card_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.rate_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.rate_view.layer.cornerRadius = (screen_width-36)/14
        let row = self.game[indexPath.row]
        
        let gesture_1 = Gesturetap(target: self, action: #selector(favorite))
        let gesture_2 = Gesturetap(target: self, action: #selector(score))
        let gesture_3 = Gesturetap(target: self, action: #selector(community))
        
        // 게임 이름
        game_cell.game_name.text = row.title
        
        // 게임 평점
        if row.rate_count == 0 {
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
        
        // 게임 플랫폼
        for platforms in row.platforms ?? [""] {
            str_temp.append(contentsOf: platforms)
            str_temp.append(contentsOf: ", ")
        }
        game_cell.game_platform.text = String(str_temp.prefix(str_temp.count - 2))
        
        // 게임 이미지
        game_cell.game_image.kf.indicatorType = .activity
        game_cell.game_image.kf.setImage(
            with: URL(string: row.images!),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 400, height: 300))),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
        ]) { result in
            gesture_2.image = game_cell.game_image.image
        }
    
        // more 버튼 타겟 추가
        game_cell.more_but.tag = row.id ?? 0
        game_cell.more_but.addTarget(self, action: #selector(more(_:)), for: .touchUpInside)
        
        gesture_1.id    = row.id
        gesture_2.title = row.title
        gesture_2.id    = row.id
        
        gesture_3.id    = row.id
        
        game_cell.favorite.addGestureRecognizer(gesture_1)
        game_cell.score.addGestureRecognizer(gesture_2)
        game_cell.community.addGestureRecognizer(gesture_3)
        
        return game_cell
    }
    
    // 테이블 뷰 높이 설정을 위한 함수
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            // 마지막 셀 로드 완료 했을때
            all_card_height.constant = (tableView.contentSize.height + 30)
        }
    }
    
    @objc func favorite() {
        custom_alert.red_alert(text: "찜했습니다.")
    }
    
    @objc func score(sender: Gesturetap) {
        custom_alert.score_alert(id: sender.id!, title: sender.title!, image: sender.image ?? UIImage(named: "ic_star_fill")!)
    }
    
    @objc func community() {
        
    }
    
    @objc func more(_ sender : UIButton) {
        self.performSegue(withIdentifier: "game_info", sender: sender.tag)
    }
    
    // 게임 정보 get
    func get_games() {
        Alamofire.request(Api.url + "games?limit=4&sort=random").responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                for subJson : JSON in json["games"].arrayValue {
                    let main = Main_VO()
                    main.id         = subJson["id"].intValue
                    main.title      = subJson["title"].stringValue
                    main.images     = subJson["images"][0].stringValue
                    main.rate       = subJson["score"].intValue
                    main.rate_count = subJson["score_count"].intValue
                    main.platforms = subJson["platforms"].arrayObject as? [String]
                    self.game.append(main)
                }
                self.refreshControl.endRefreshing()
                self.load_indicator.stopAnimating()
                self.scroll.isHidden = false
                self.table.reloadData()
            } else {
                self.showalert(message: "서버 응답 오류", can: 0)
            }
        }
    }
    
    // 게임 상세보기 뷰 prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.game_id = sender as! Int
    }
    
}


// 평가하기 파라미터 클래스
class Gesturetap: UITapGestureRecognizer {
    var title: String?
    var image: UIImage?
    var id: Int?
}
