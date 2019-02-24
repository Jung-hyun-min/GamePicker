import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Game_search: UIViewController {
    @IBOutlet var search_table: UITableView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var state: UILabel!
    
    @IBOutlet var search_bar: UISearchBar!
    
    var all_game_arr = [Game_VO]() // 모든 게임을 저장할 배열
    
    var searched_game_arr = [Game_VO]() // 저장된 게임을 저장할 배열
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        get_game()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.game_id = sender as? Int
    }
    
    
    func get_game() {
        Alamofire.request(Api.url + "games", headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)

                switch response.response?.statusCode {
                case 200:
                    let arr = json["games"].arrayValue
                    print("\(arr.count) games")
                    
                    for subJson: JSON in arr {
                        let game = Game_VO()
                        
                        game.id        = subJson["id"].intValue
                        game.title     = subJson["title"].stringValue
                        game.thumbnail = subJson["images"][0].stringValue
                        
                        self.all_game_arr.append(game)
                    }
                    
                    // 배열 복사
                    self.searched_game_arr = self.all_game_arr
                    self.state.isHidden = false
                    self.search_bar.isHidden = false
                    self.indicator.stopAnimating()
                    
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
            }
            
            response.result.ifFailure { self.showalert(message: "네트워크 연결 실패", can: 0) }
        }
    }
}

extension Game_search: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searched_game_arr.count == 0 {
            tableView.isHidden = true
            if search_bar.text!.isEmpty {
                state.text = "검색어를 입력하세요"
            } else {
                state.text = "\"\(search_bar.text ?? "")\"(은)는 없습니다"
            }
        } else {
            tableView.isHidden = false
        }
        return searched_game_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game_cell = tableView.dequeueReusableCell(withIdentifier: "game") as! Game_search_cell
        let row = self.searched_game_arr[indexPath.row]
        game_cell.game_title?.text = row.title
        game_cell.game_image.kf.indicatorType = .activity
        
        // 이미지 설정
        game_cell.game_image.kf.setImage(
            with: URL(string: row.thumbnail!),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 120, height: 80))),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                ])
        return game_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "game_info", sender: searched_game_arr[indexPath.row].id)
    }
}

extension Game_search: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searched_game_arr = all_game_arr.filter({ game -> Bool in
            if search_bar.text!.isEmpty {
                return false
            } else {
                if let game_title = game.title {
                    return game_title.lowercased().contains(search_bar.text!.lowercased())
                }
            }
            return false
        })
        search_table.reloadData()
    }
}
