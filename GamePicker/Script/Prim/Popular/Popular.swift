import UIKit

class Popular: UIViewController {
    @IBOutlet var popular_online: UIButton!
    @IBOutlet var top_rating: UIButton!
    @IBOutlet var popular_mobile: UIButton!
    @IBOutlet var search: UIButton!
    
    var flag = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 스와이프 제스쳐 추가
    }
    
    @IBAction func first(_ sender: Any) {
        flag = 1
        self.performSegue(withIdentifier: "game_list", sender: self)
    }
    
    @IBAction func second(_ sender: Any) {
        flag = 2
        self.performSegue(withIdentifier: "game_list", sender: self)
    }
    
    @IBAction func third(_ sender: Any) {
        flag = 3
        self.performSegue(withIdentifier: "game_list", sender: self)
    }
    
    @IBAction func fourth(_ sender: Any) {
        flag = 4
        self.performSegue(withIdentifier: "game_list", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Game_List
        param.flag = flag
    }
}
