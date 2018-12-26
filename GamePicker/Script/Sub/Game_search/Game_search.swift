import UIKit
import Alamofire
import SwiftyJSON

class Game_search: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var search_table: UITableView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var search_bar: UISearchBar!
    @IBOutlet var state: UILabel!
    
    let api = Api_url()
    
    let imageCache = NSCache<NSString, UIImage>()
    
    // 모든 게임을 저장할 배열
    lazy var all_game : [Game_VO] = {
        var datalist = [Game_VO]()
        return datalist
    }()
    
    // 저장된 게임을 저장할 배열
    lazy var searched_game : [Game_VO] = {
        var datalist = [Game_VO]()
        return datalist
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search_bar.isHidden = true
        state.isHidden = true
        
        // 서치바 색 변경
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        // http get
        get_games()
    }
    
    // 게임데이터 get request
    func get_games() {
        // 액티비티 회전 시작
        activity.startAnimating()
        
        let url = api.pre + "games"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    let count = json["data"]["count"].intValue
                    print("\(count) games in DB")
                    for (_,subJson):(String, JSON) in json["data"]["games"] {
                        let gme = Game_VO()
                        // movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                        gme.id        = subJson["id"].intValue
                        gme.title     = subJson["title"].stringValue
                        gme.thumbnail = subJson["img_link"].stringValue
                        self.all_game.append(gme)
                    }
                    self.searched_game = self.all_game
                    DispatchQueue.main.async(execute: {
                        self.state.isHidden = false
                        self.search_bar.isHidden = false
                        self.state.text = "검색어를 입력하세요"
                        self.activity.stopAnimating()
                        self.activity.isHidden = true
                    })
                }
            } else {
                self.showalert(message: "게임 데이터 API 오류", can: 0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searched_game.count == 0 {
            tableView.isHidden = true
            if search_bar.text == "" {
                state.text = "검색어를 입력하세요"
            } else {
                state.text = "\"\(search_bar.text ?? "")\"(은)는 없습니다"
            }
            return 0
        } else {
            tableView.isHidden = false
            return searched_game.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game_search_cell") as! Game_search_cell
        
        let row = self.searched_game[indexPath.row]
        
        cell.game_title?.text = row.title
        
        
        
        
       
        if let url = URL(string :row.thumbnail ?? "") {
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    cell.game_image.image = UIImage(data: data)
                }
            }
        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.searched_game[indexPath.row]
        let game_id : Int = row.id ?? 0
        print("ID : \(game_id)")
        self.performSegue(withIdentifier: "game_info2", sender: game_id)
    }
    
    // 값 넘김
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.id = sender as! Int
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searched_game = all_game.filter({ game -> Bool in
            if search_bar.text == "" {
                return false
            } else {
                if let game_title = game.title {
                    return game_title.lowercased().contains(search_bar.text!.lowercased())

                }
            }
            return false
        })
        search_table.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searched_game = all_game.filter({ game -> Bool in
            if search_bar.text == "" {
                return false
            } else {
                if let game_title = game.title {
                    return game_title.lowercased().contains(search_bar.text!.lowercased())
                    
                }
            }
            return false
        })
        search_table.reloadData()
        //searchBar.resignFirstResponder()

    }
    
}
