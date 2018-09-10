import UIKit
import Firebase
import FBSDKCoreKit

class Setting: UIViewController {
    
    @IBOutlet var Profile_image: UIImageView!
    @IBOutlet var Back_image: UIImageView!
    @IBOutlet var User_email: UILabel!
    @IBOutlet var User_name: UILabel!
    let User_data = UserDefaults.standard
    
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
        
        //User_name.text = Auth.auth().currentUser?.displayName
        Profile_chk()
        
        Profile_image.layer.masksToBounds = true
        Profile_image.layer.cornerRadius = Profile_image.frame.size.height/2;
        Profile_image.layer.borderWidth = 0.2
        Profile_image.layer.borderColor = UIColor.white.cgColor
        Profile_image.clipsToBounds = true;
        
        let tapGesture_back = UITapGestureRecognizer(target: self, action: #selector(self.Edit))
        let tapGesture_front = UITapGestureRecognizer(target: self, action: #selector(self.Edit))
        Back_image.addGestureRecognizer(tapGesture_back)
        Back_image.isUserInteractionEnabled = true
        Profile_image.addGestureRecognizer(tapGesture_front)
        Profile_image.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Profile_chk()
    }
    
    func Profile_chk() {
        User_email.text = User_data.string(forKey: "User_ID")
        User_name.text = User_data.string(forKey: "User_name")
        if let front_image = User_data.object(forKey: "User_front_picture") {
            Profile_image.image = UIImage(data: front_image as! Data)
        } else {
            Profile_image.image = UIImage(named: "front_default")
        }
        if let back_image = User_data.object(forKey: "User_back_picture") {
            Back_image.image = UIImage(data: back_image as! Data)
        } else {
            Back_image.image = UIImage(named: "back_default2.png")
        }
    }
    
    @objc func Edit() {
        let alert = UIAlertController(title: "프로필", message: "수정 하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default){
            (result:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "Edit", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "알림", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .destructive){
            (result:UIAlertAction) -> Void in
            do {
                try Auth.auth().signOut()
            } catch  {
            }
            self.performSegue(withIdentifier: "Login", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
}
