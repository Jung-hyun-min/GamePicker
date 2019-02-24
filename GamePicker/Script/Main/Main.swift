import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import SVPullToRefresh


class Main: UIViewController {
    @IBOutlet var container_scroll: UIScrollView!
    @IBOutlet var container_stack: UIStackView!
    
    @IBOutlet var game_table: UITableView!
    @IBOutlet var message_view: UIView!
    
    @IBOutlet var message_notify: UIView!
    @IBOutlet var message_main: UILabel!
    @IBOutlet var message_sub: UILabel!
    @IBOutlet var message_yes: UIButton!
    @IBOutlet var message_no: UIButton!
    @IBOutlet var message_close: UIButton!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    let refresh_view = Bundle.main.loadNibNamed("Refresh_view", owner: self, options: nil)?.first as? Refresh_view
    
    let stack_functions = User_stack()
    let message_functions = User_message()
    let impact = UIImpactFeedbackGenerator()
    
    var game_arr = [Main_VO]()

    var isRefreshing: Bool = false
    var isPossible_refreshing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation_icon() // 네비게이션 아이콘
        get_game()
        
        //navigationController?.hidesBarsOnSwipe = true
        
        container_scroll.isHidden = true // 스크롤 뷰 숨기고 인디케이터 에니메이션 시작
        
        message_notify.layer.borderColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0).cgColor
        stack_functions.parent = self
        
        message_functions.message_view = self.message_view
        message_functions.main_title = self.message_main
        message_functions.sub_title = self.message_sub
        
        message_no.addTarget(message_functions, action: #selector(message_functions.response_no), for: .touchUpInside)
        message_yes.addTarget(message_functions, action: #selector(message_functions.response_yes), for: .touchUpInside)
        message_close.addTarget(message_functions, action: #selector(message_functions.hide_view), for: .touchUpInside)
        
        message_functions.main_message()
        
        container_scroll.addPullToRefresh {
            self.game_arr.removeAll()
            self.get_game()
        }
        
        container_scroll.pullToRefreshView.setCustom(refresh_view, forState: 0)
        container_scroll.pullToRefreshView.setCustom(refresh_view, forState: 1)
        container_scroll.pullToRefreshView.setCustom(refresh_view, forState: 2)
        container_scroll.pullToRefreshView.setCustom(refresh_view, forState: 3)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.game_id = sender as? Int
    }

    
    @objc func more(_ sender : UIButton) {
        self.performSegue(withIdentifier: "game_info", sender: sender.tag)
    }
    
    
    func process_data() {
        let favor_score_group = DispatchGroup()
        
        for game in game_arr {
            favor_score_group.enter()
            favor_score_group.enter()
            
            self.get_favor(game.id!) { result in
                game.Isfavor = result
                favor_score_group.leave()
            }
            
            self.get_score(game.id!) { result in
                game.Isscore = result
                favor_score_group.leave()
            }
        }
        
        favor_score_group.notify(queue: .main) {
            self.indicator.stopAnimating()
            self.container_scroll.isHidden = false
            self.game_table.reloadData()
            
            self.container_scroll.pullToRefreshView.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.container_scroll.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    /* request functions */
    func get_game() {
        Alamofire.request(Api.url + "games?limit=4&sort=random", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                for subJson: JSON in json["games"].arrayValue {
                    let game = Main_VO()
                    
                    game.id          = subJson["id"].intValue
                    game.title       = subJson["title"].stringValue
                    game.images      = subJson["images"][0].stringValue
                    game.score       = subJson["score"].doubleValue
                    game.score_count = subJson["score_count"].intValue
                    game.platforms   = subJson["platforms"].arrayObject as? [String]
                    
                    self.game_arr.append(game)
                    
                }
                self.process_data()
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 1)
            }
        }
        
    }
    
    func get_score(_ id: Int, completionHandler : @escaping (Double) -> Void) {
        Alamofire.request(Api.url + "games/\(id)/score", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                switch response.response?.statusCode ?? 0 {
                case 200: completionHandler(json["score"].doubleValue)
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
    
    func get_favor(_ id: Int, completionHandler : @escaping (Bool) -> Void) {
        Alamofire.request(Api.url + "games/\(id)/favor", headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                switch response.response?.statusCode ?? 0 {
                case 200:
                    
                    switch json["favor"].boolValue {
                    case true: completionHandler(true)
                    default: completionHandler(false)
                    }
                    
                case ...500: self.showalert(message: json["message"].stringValue, can: 0)
                default : self.showalert(message: "서버 오류", can: 0)
                }
            }
            
            response.result.ifFailure {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}


extension Main: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game_cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! Main_cell
        var str_temp : String = ""
        game_cell.card_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.game_myscore_view.layer.shadowColor = UIColor.black.cgColor
        game_cell.game_myscore_view.layer.cornerRadius = (UIScreen.main.bounds.width-36)/14
        
        let row = self.game_arr[indexPath.row]
        
        // 게임 이름
        game_cell.game_name.text = row.title
        
        // 게임 평점
        if row.score_count == 0 {
            game_cell.game_score.text = "평가없음"
            game_cell.game_score_count.text = "0"
        } else {
            game_cell.game_score.text = "\(round(row.score! * 100)/100)"
            game_cell.game_score_count.text = String(row.score_count!)
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
            game_cell.evaluate_but.game_image = game_cell.game_image.image
        }
        
        // more 버튼 타겟 추가
        game_cell.more_but.tag = row.id ?? 0
        game_cell.more_but.addTarget(self, action: #selector(more(_:)), for: .touchUpInside)
        
        // 찜한 게임인지 판단
        if row.Isfavor ?? false {
            game_cell.favorite_image.image = UIImage(named: "ic_heart_fill")
            game_cell.favorite_but.isDone = true
        } else {
            game_cell.favorite_image.image = UIImage(named: "ic_heart_empty")
            game_cell.favorite_but.isDone = false
        }
        
        if row.Isscore == 0 {
            game_cell.game_myscore_view.isHidden = true
            game_cell.evaluate_but.isDone = false
        } else {
            game_cell.game_myscore_view.isHidden = false
            game_cell.game_myscore.text = String(row.Isscore!)
            game_cell.evaluate_but.isDone = true
            game_cell.evaluate_but.self_myscore_value = row.Isscore
        }
        
        // user stack 파라미터
        game_cell.favorite_but.game_id = row.id ?? 0
        game_cell.favorite_but.self_image = game_cell.favorite_image
        
        
        game_cell.evaluate_but.game_id = row.id ?? 0
        game_cell.evaluate_but.game_title = row.title
        game_cell.evaluate_but.self_score_value = game_cell.game_score
        game_cell.evaluate_but.self_score_count = game_cell.game_score_count
        game_cell.evaluate_but.self_myscore_view = game_cell.game_myscore_view
        game_cell.evaluate_but.self_myscore = game_cell.game_myscore
        game_cell.evaluate_but.game_score_value = row.score
        game_cell.evaluate_but.game_score_count = row.score_count
        
        game_cell.community_but.game_id = row.id ?? 0
        game_cell.community_but.game_title = row.title
        
        game_cell.favorite_but.addTarget(stack_functions, action: #selector(stack_functions.favorite(_:)), for: .touchUpInside)
        game_cell.evaluate_but.addTarget(stack_functions, action: #selector(stack_functions.evaluate(_:)), for: .touchUpInside)
        game_cell.community_but.addTarget(stack_functions, action: #selector(stack_functions.community(_:)), for: .touchUpInside)
        
        return game_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "game_info", sender: game_arr[indexPath.row].id)
    }
}

extension Main: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            switch self.container_scroll.pullToRefreshView.state {
            case 0:
                if isRefreshing == true {
                    print("새로고침 끝")
                    isRefreshing = false
                    refresh_view?.state_message.text = "완료!"
                } else {
                    if isPossible_refreshing == false {
                        print("새로고침 불가능 지역")
                        isPossible_refreshing = true
                        refresh_view?.state_message.text = "위로 올리면 새로고침 됩니다."
                    }
                }
                
            case 1:
                if isPossible_refreshing == true {
                    print("새로고침 가능 지역")
                    refresh_view?.state_message.text = "손을 떼면 새로고침 시작"
                    isPossible_refreshing = false
                    impact.impactOccurred()
                }
                
            case 2:
                if isRefreshing == false {
                    print("새로고침 시작")
                    refresh_view?.state_message.text = "새로운 게임 탐색중"
                    isRefreshing = true
                }
                
            default: break
            }
        }
    }
}
