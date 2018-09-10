import UIKit

class Game_List: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var game_table: UITableView!
    
    var game_array = ["배틀그라운드","롤"]
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if flag == 1 { // 1 : 인기 온라인 게임 2 : 높은 평점 게임 3 : 인기 모바일 게임 4 : 탐색
            self.title = "인기 온라인 게임"
        } else if flag == 2 {
            self.title = "높은 평점 게임"
        } else if flag == 3 {
            self.title = "인기 모바일 게임"
        } else if flag == 4 {
            self.title = "탐색"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game_cell")
        cell?.textLabel?.text = game_array[indexPath.row]
        return cell!
    }

}
