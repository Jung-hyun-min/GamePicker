import UIKit
import Alamofire
import SwiftyJSON

class Game_search: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet var search_table: UITableView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var search_bar: UISearchBar!
    @IBOutlet var state: UILabel!
    
    let api = Api_url()
    
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
        // 서치바 색 변경
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
    
        // http get
        getgames()
    }
    
    // 네비게이션 아이템 새로고침
    @IBAction func refresh(_ sender: Any) {
        self.activity.startAnimating()
        state.text = "게임정보 동기화중.."
        all_game.removeAll()
        searched_game.removeAll()
        getgames()
    }
    
    // 게임데이터 get request
    func getgames() {
        // 액티비티 회전 시작
        activity.startAnimating()
        search_table.isHidden = true // 테이블 뷰 가리기
        
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
                        self.state.text = "검색어를 입력해주세요"
                        self.activity.stopAnimating()
                        self.activity.isHidden = true
                    })
                }
            } else {
                self.showalert(message: "게임 데이터 API 오류")
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
        
        DispatchQueue.main.async(execute: {
            cell.game_image.image = self.getThumbnailImage(indexPath.row)
        })
        return cell
    }
    
    func getThumbnailImage(_ index : Int) -> UIImage {
        // 인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let game = self.searched_game[index]
        // 메모리제이션 처리 저장된 이미지가 있을 경우 이를 반환하고, 없을 경우 내려받아 저장한 후 반환함
        let nullimage = UIImage(named: "noimage.jpg")
        
        let url: URL! = URL(string: game.thumbnail!)
        
        if url != nil {
            let imageData = try! Data(contentsOf: url)
            game.thumbnailImage = UIImage(data:imageData) // UIImage 객체를 생성하여 MovieVO 객체에 우선 저장함
            if game.thumbnailImage != nil {
                // 이미지 값이 비어있지 않고, 이미지 url이 유효할때
                return game.thumbnailImage!
            } else {
                return nullimage!  // 저장된 이미지를 반환
            }
        } else {
            return nullimage!
        }
        
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
    
    func showalert(message : String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        self.present(alert,animated: true)
        return
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
}
