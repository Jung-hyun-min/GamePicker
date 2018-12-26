import UIKit

class Setting: UIViewController {
    @IBOutlet var back_height: NSLayoutConstraint!
    @IBOutlet var padding0: NSLayoutConstraint!
    @IBOutlet var padding1: NSLayoutConstraint!
    @IBOutlet var padding2: NSLayoutConstraint!
    @IBOutlet var padding3: NSLayoutConstraint!
    @IBOutlet var padding4: NSLayoutConstraint!
    @IBOutlet var padding5: NSLayoutConstraint!
    @IBOutlet var padding6: NSLayoutConstraint!
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
    let gradient = CAGradientLayer()
    
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
        
        premium.layer.borderColor = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        logout.layer.borderColor  = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        print(size.height)
        if size.height == 480 {
            analyze_padding1.constant = -10
            under_padding.constant = 40
            back_height.constant = 100
            padding0.constant = 5
            padding1.constant = 27
            padding2.constant = 5
            padding3.constant = 2
            padding4.constant = 30
            padding5.constant = 28
            padding6.constant = 5
        }
        else if size.height == 568 { // iphone_5
            analyze_padding1.constant = -10
            under_padding.constant = 50
            back_height.constant = 140
            padding0.constant = 10
            padding1.constant = 37
            padding2.constant = 10
            padding3.constant = 2
            padding4.constant = 40
            padding5.constant = 38
            padding6.constant = 10
        }
        else if size.height == 667 { // iphone_8
            back_height.constant = 170
            padding0.constant = 20
            padding2.constant = 20
            padding3.constant = 10
            padding6.constant = 12
        }
        else if size.height == 812 { // iphone_x
            padding1.constant = 70
        }
        else if size.height == 896 { // iphone_x max
            padding0.constant = 30
            padding1.constant = 100
            back_height.constant = 275
        }
        
        gradient.colors = [
            UIColor(red:0.35, green:0.43, blue:0.49, alpha:1.0).cgColor,
            UIColor(red:0.49, green:0.60, blue:0.68, alpha:1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.5)
        analyze1.layer.addSublayer(gradient)
        analyze2.layer.addSublayer(gradient)
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
        let alert = UIAlertController(title: nil, message: "로그아웃하시겠어요?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .destructive) {
            (result:UIAlertAction) -> Void in
            UserDefaults.standard.set(false, forKey: "login")
            self.delete_userdata()
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
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
    
}
