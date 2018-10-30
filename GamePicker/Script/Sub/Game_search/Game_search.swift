import UIKit

class Game_search: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var search_table: UITableView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var search_bar: UISearchBar!
    
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
        search_table.allowsSelection = true
        // 서치바 색 변경
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        // 서치바 이외의 공간 제스쳐리코그나이저 추가
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        // URL 데이터 받아옴
        getdata()
    }
    
    @objc func endEditing() {
        search_bar.resignFirstResponder()
    }
    
    @IBAction func refresh(_ sender: Any) {
        all_game.removeAll()
        searched_game.removeAll()
        getdata()
    }
    
    // 데이터 받아옴
    func getdata() {
        // 액티비티 회전 시작
        activity.isHidden = false
        activity.startAnimating()
        search_table.isHidden = true // 테이블 뷰 가리기
        // 배열 삭제
        
        let urltext: String = "http://gamepicker-api.appspot.com/games"
        // url 안될시 깔끔 포기
        guard let url = URL(string: urltext) else {
            print("Error: cannot create URL")
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error calling POST on /games")
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                let apidictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as! NSDictionary
                let data = apidictionary["data"] as! NSDictionary
                let games = data["games"] as! NSArray
                
                let count = data["count"] as? Int
                print("\(count ?? 0) games")
                for row in games {
                    // 순회 상수를 NSDictionary 타입으로 캐스팅
                    let r = row as! NSDictionary
                    // 테이블 뷰 리스트를 구성할 데이터 형식
                    let gme = Game_VO()
                    // movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                    gme.id        = r["id"] as? Int
                    gme.title     = r["title"] as? String
                    gme.thumbnail = r["img_link"] as? String
                    // 웹상에 있는 이미지를 읽어와 UIImage 객체로 생성
                    if gme.thumbnail != "" {
                        let url: URL! = URL(string: gme.thumbnail!)
                        let imageData = try! Data(contentsOf: url)
                        gme.thumbnailImage = UIImage(data:imageData)
                    }
                       // all_game 배열에 값 추가
                    self.all_game.append(gme)
                }
                self.searched_game = self.all_game
                DispatchQueue.main.async(execute: {
                    self.search_table.isHidden = false
                    self.activity.stopAnimating()
                    self.activity.isHidden = false
                    self.search_table.reloadData()
                })
            } catch {
                print("Parse Error!!")
                return
            }
            
        }
        .resume()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searched_game.count
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.searched_game[indexPath.row]
        let game_id : Int = row.id ?? 0
        print("\(game_id)")
        performSegue(withIdentifier: "game_info2", sender: game_id)
    }
    
    // 값 넘김
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_info
        param.id = sender as! Int
    }
    
    func getThumbnailImage(_ index : Int) -> UIImage {
        // 인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let gme = self.searched_game[index]
        // 메모리제이션 처리 저장된 이미지가 있을 경우 이를 반환하고, 없을 경우 내려받아 저장한 후 반환함
        
        let nullimage = UIImage(named: "noimage.jpg")
        
        if let savedImage = gme.thumbnailImage {
            return savedImage
        } else {
            let url: URL! = URL(string: gme.thumbnail!)
            if url != nil {
                let imageData = try! Data(contentsOf: url)
                gme.thumbnailImage = UIImage(data:imageData) // UIImage 객체를 생성하여 MovieVO 객체에 우선 저장함
                if gme.thumbnailImage != nil {
                    // 이미지 값이 비어있지 않고, 이미지 url이 유효할때
                    return gme.thumbnailImage!
                }
                return nullimage!  // 저장된 이미지를 반환
            } else {
                return nullimage!
            }
        }
    }
}

extension Game_search: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searched_game = all_game.filter({ game -> Bool in
        if searchText.isEmpty { return true }
        else {
            if let game_title = game.title {
                return game_title.lowercased().contains(searchText.lowercased())
            }
        }
            return false
        })
        search_table.reloadData()
    }
    
    // 서치버튼 클릭시 퍼스트리스폰더 리사인
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
