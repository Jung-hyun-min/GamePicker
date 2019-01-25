import UIKit
import SwiftyJSON
import SwiftMessages
import Alamofire
import Kingfisher

class Profile: UIViewController {
    @IBOutlet var back_height: NSLayoutConstraint!
    @IBOutlet var stack_height: NSLayoutConstraint!
    @IBOutlet var notify_height: NSLayoutConstraint!
    
    @IBOutlet var padding1: NSLayoutConstraint!
    @IBOutlet var padding2: NSLayoutConstraint!
    @IBOutlet var under_padding: NSLayoutConstraint!
    @IBOutlet var close_view: UIView! // 메세지 뷰
    
    @IBOutlet var profile_but: UIButton! // 프로필 이미지
    @IBOutlet var background_but: UIButton! // 배경 이미지
    @IBOutlet var user_name: UILabel!   // 이름
    @IBOutlet var user_intro: UILabel!  // 소개
    
    @IBOutlet var premium: UIButton!
    @IBOutlet var logout: UIButton!
    
    @IBOutlet var analyze1: UIView!
    @IBOutlet var analyze2: UIView!
    @IBOutlet var analyze_padding1: NSLayoutConstraint!
    
    @IBOutlet var premium_img: UIView!
    @IBOutlet var premium_txt: UILabel!
    
    let size = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        close_view.isHidden = false
        
        background_but.addSubview(profile_but)
        profile_but.layer.cornerRadius  = size.width/8
        profile_but.layer.borderColor   = UIColor.white.cgColor
        profile_but.contentMode = .scaleAspectFit
        background_but.contentMode = .scaleAspectFit
        
        stack_height.constant = size.width/4
        
        premium.layer.borderColor = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        logout.layer.borderColor  = UIColor(red:0.54, green:0.60, blue:0.64, alpha:1.0).cgColor
        
        // 기기별 높이 정렬 수정 필요
        if size.height == 480 {
            analyze_padding1.constant = -10
            under_padding.constant = 60
            notify_height.constant = 40
            padding1.constant = 15
            back_height.constant = 100
        } else if size.height == 568 { // iphone_5
            analyze_padding1.constant = -10
            under_padding.constant = 60
            notify_height.constant = 40
            padding1.constant = 15
            back_height.constant = 73
        } else if size.height == 667 { // iphone_8
            padding1.constant = 30
            back_height.constant = 37
        } else if size.height == 812 { // iphone_x
            padding1.constant = 65
            back_height.constant = -55
        } else if size.height == 896 { // iphone_xr
            padding1.constant = 95
            padding2.constant = 30
            back_height.constant = -76
        }
    }
    
    @IBAction func close(_ sender: Any) {
        close_view.isHidden = true
        under_padding.constant = 20
    }
    
    // Apper 프로필 체크
    override func viewWillAppear(_ animated: Bool) {
        profile_chk()
    }
    
    // User default 에서 유저 정보 retrive
    func profile_chk() {
        let User_data = UserDefaults.standard
        
        if let name = User_data.string(forKey: data.user.name) {
            user_name.text = name
        }
        
        // 자기소개
        if let introduce = User_data.string(forKey: data.user.introduce) {
            if introduce.isEmpty {
                user_intro.text = introduce
            }
        } else {
            user_intro.text = "한줄소개를 입력해 주세요."
        }
        
        // 프로필 사진
        if let front_image = User_data.object(forKey: data.user.profile) {
            profile_but.setImage(UIImage(data: front_image as! Data), for: .normal)
            profile_but.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            profile_but.setImage(UIImage(named: "ic_profile"), for: .normal)
            profile_but.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        
        // 아직 배경사진 기능 서버에 없음 2019-1-18
        /*
        if let back_image = User_data.object(forKey: "User_back_picture") {
            background.image = UIImage(data: back_image as! Data)
        } else {
            background.image = UIImage(named: "img_bg")
        }
        */
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
        view.logoutAction = {
            SwiftMessages.hide()
            UserDefaults.standard.set(false, forKey: data.isLogin)
            self.performSegue(withIdentifier: "logout", sender: self)
        }
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.dimMode = .color(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8), interactive: true)
        
        SwiftMessages.show(config: config, view: view)
    }
    
    // 배경 이미지 터치 실행 함수
    @IBAction func background(_ sender: Any) {
        print("back")
    }
    
    // 프로필 이미지 터치 실행 함수
    @IBAction func profile(_ sender: Any) {
        print("profile")
    }
    
    // 프리미엄 등록
    @IBAction func premium(_ sender: Any) {
        premium.isHidden = true
        premium_img.isHidden = false
        premium_txt.isHidden = false
    }
    
}
