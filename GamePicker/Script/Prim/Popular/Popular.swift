import UIKit

class Popular: UIViewController {
    @IBOutlet var popular_online: UIButton!
    @IBOutlet var top_rating: UIButton!
    @IBOutlet var popular_mobile: UIButton!
    @IBOutlet var search: UIButton!
    
    var flag = Int()
    
    @objc  func swiped(_ gesture: UISwipeGestureRecognizer) { // 탭바 스와이프 제스쳐
        if gesture.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 3 {
                self.tabBarController?.selectedIndex += 1
            }
        } else if gesture.direction == .right {
            if (self.tabBarController?.selectedIndex)! > 0 {
                self.tabBarController?.selectedIndex -= 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 스와이프 제스쳐 추가
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
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
