import UIKit

class Popular: UIViewController {
    @IBOutlet var popular_online: UIImageView!
    @IBOutlet var top_rating: UIImageView!
    @IBOutlet var popular_mobile: UIImageView!
    @IBOutlet var search: UIImageView!
    
    var flag = Int()
    
    @objc  func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if (self.tabBarController?.selectedIndex)! < 3
            { // set here  your total tabs
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
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
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
