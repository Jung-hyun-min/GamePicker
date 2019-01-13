import UIKit
import SwiftyJSON
import SwiftMessages
import Alamofire

class Setting: UIViewController {
    @IBOutlet var back_height: NSLayoutConstraint!
    @IBOutlet var stack_height: NSLayoutConstraint!
    @IBOutlet var notify_height: NSLayoutConstraint!
    
    @IBOutlet var padding1: NSLayoutConstraint!
    @IBOutlet var padding2: NSLayoutConstraint!
    @IBOutlet var under_padding: NSLayoutConstraint!
    @IBOutlet var close_view: UIView!
    
    @IBOutlet var profile_but: UIButton!
    @IBOutlet var profile: UIImageView!    // 프로필 사진
    @IBOutlet var background: UIImageView!
    @IBOutlet var user_name: UILabel!   // 이름
    @IBOutlet var user_intro: UILabel!  // 소개
    
    @IBOutlet var premium: UIButton!
    @IBOutlet var logout: UIButton!
    
    @IBOutlet var analyze1: UIView!
    @IBOutlet var analyze2: UIView!
    @IBOutlet var analyze_padding1: NSLayoutConstraint!
    
    @IBOutlet var premium_img: UIView!
    @IBOutlet var premium_txt: UILabel!
    
    
    let User_data = UserDefaults.standard
    let size = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        premium_img.isHidden = true
        premium_txt.isHidden = true
        Profile_chk()
        
        close_view.isHidden = false
        under_padding.constant = 80
        profile.layer.cornerRadius  = size.width/8
        profile.layer.borderColor   = UIColor.white.cgColor
        profile_but.layer.cornerRadius  = size.width/8
        profile_but.layer.borderColor   = UIColor.white.cgColor
        stack_height.constant = size.width/4
        
        premium.layer.borderColor = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        logout.layer.borderColor  = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        print(size.height)
        if size.height == 480 {
            analyze_padding1.constant = -10
            under_padding.constant = 60
            notify_height.constant = 40
            padding1.constant = 15
            back_height.constant = 90
        } else if size.height == 568 { // iphone_5
            analyze_padding1.constant = -10
            under_padding.constant = 60
            notify_height.constant = 40
            padding1.constant = 20
            back_height.constant = 71
        } else if size.height == 667 { // iphone_8
            padding1.constant = 33
            back_height.constant = 30
        } else if size.height == 812 { // iphone_x
            padding1.constant = 70
            back_height.constant = -55
        } else if size.height == 896 { // iphone_xr
            padding1.constant = 97
            back_height.constant = -100
        }

    }
    
    @IBAction func close(_ sender: Any) {
        close_view.isHidden = true
        under_padding.constant = 20
    }
    
    // Apper 프로필 체크
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.Profile_chk()
        })
    }
    
    func Profile_chk() { // 화면에 프로필 표시
        if let name = User_data.string(forKey: "User_name") { // 이름
            user_name.text = name
        } else {
            user_name.text = "닉네임"
        }
        if let intro = User_data.string(forKey: "User_introduce") { // 소개
            if intro == "" {
                user_intro.text = "한줄소개를 입력해 주세요."
            } else {
                user_intro.text = intro
            }
        } else {
            user_intro.text = "한줄소개를 입력해 주세요."
        }
        if let front_image = User_data.object(forKey: "User_front_picture") { // 프사
            profile.image = UIImage(data: front_image as! Data)
        } else {
            profile.image = UIImage(named: "ic_profile.png")
        }
        if let back_image = User_data.object(forKey: "User_back_picture") { // 배사
            background.image = UIImage(data: back_image as! Data)
        } else {
            background.image = UIImage(named: "img_bg.png")
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        let alert = UIAlertController(title: "프로필", message: "수정 하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "edit", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    // 로그아웃 버튼
    @IBAction func logout(_ sender: Any) {
        let view: Center_logout = try! SwiftMessages.viewFromNib()
        view.cancelAction = { SwiftMessages.hide() }
        view.logoutAction = {
            SwiftMessages.hide()
            UserDefaults.standard.set(false, forKey: "login")
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.dimMode = .color(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8), interactive: true)
        
        SwiftMessages.show(config: config, view: view)
    }
    
    @IBAction func background(_ sender: Any) {
        print("back")
    }
    
    @IBAction func profile(_ sender: Any) {
        print("profile")
    }
    
    @IBAction func premium(_ sender: Any) {
        premium.isHidden = true
        premium_img.isHidden = false
        premium_txt.isHidden = false
    }
    
    func user_delete() {
        UserDefaults.standard.removeObject(forKey: "User_point")
        UserDefaults.standard.removeObject(forKey: "User_gender")
        UserDefaults.standard.removeObject(forKey: "User_name")
        UserDefaults.standard.removeObject(forKey: "User_email")
        UserDefaults.standard.removeObject(forKey: "User_introduce")
        UserDefaults.standard.removeObject(forKey: "User_admin")
        UserDefaults.standard.removeObject(forKey: "User_birthday")
        UserDefaults.standard.removeObject(forKey: "User_premium")
        UserDefaults.standard.removeObject(forKey: "User_id")
    }
    
}
