import UIKit
import Alamofire

class Api {
    static let url: String = "http://api.gamepicker.co.kr/"
    
    static var authorization: [String: String] = [
        "authorization": "w6mgLXNHbPgewJtRESxh",
        "x-access-token": UserDefaults.standard.string(forKey: data.user.token) ?? ""
    ]
}

final class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    var MainSB: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    func instanceMainVC(name: String) -> UIViewController? {
        return self.MainSB.instantiateViewController(withIdentifier: name)
    }
    
    // 커스텀 클래스로 이사갈 예정
    func showalert(message: String, can: Int) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { UIAlertAction in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        switch can {
        case 0: alert.addAction(ok) // 0 이면 뒤로가기 추가
        case 1: alert.addAction(cancel) // 1 이면 뒤로 가기 없음
        default: break
        }
        self.present(alert,animated: true)
    }
    
    func navigation_icon() {
        let logo_but: UIButton = UIButton.init(type: .custom)
        logo_but.setImage(UIImage(named: "img_logo_thumb")!, for: UIControl.State.normal)
        logo_but.addTarget(self, action: #selector(self.navi_logo), for: UIControl.Event.touchUpInside)
        logo_but.frame = CGRect(x: 0, y: 0, width: 25, height: 40)
        let logo_item = UIBarButtonItem(customView: logo_but)
        
        let title_txt: UILabel = UILabel.init()
        title_txt.text = "GAMEPICKER"
        title_txt.textColor = UIColor.white
        title_txt.font = UIFont.boldSystemFont(ofSize: 19)
        title_txt.textAlignment = .center
        let title_item = UIBarButtonItem(customView: title_txt)
        
        let alarm_but: UIButton = UIButton.init(type: .custom)
        alarm_but.setImage(UIImage(named: "ic_alarm")!, for: UIControl.State.normal)
        alarm_but.addTarget(self, action: #selector(self.navi_alarm), for: UIControl.Event.touchUpInside)
        alarm_but.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        let alarm_item = UIBarButtonItem(customView: alarm_but)
        
        let message_but: UIButton = UIButton.init(type: .custom)
        message_but.setImage(UIImage(named: "ic_message")!, for: UIControl.State.normal)
        message_but.addTarget(self, action: #selector(self.navi_message), for: UIControl.Event.touchUpInside)
        message_but.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        let message_item = UIBarButtonItem(customView: message_but)
        
        let search_but: UIButton = UIButton.init(type: .custom)
        search_but.setImage(UIImage(named: "ic_search")!, for: UIControl.State.normal)
        search_but.addTarget(self, action: #selector(self.navi_search), for: UIControl.Event.touchUpInside)
        search_but.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        let search_item = UIBarButtonItem(customView: search_but)
        search_item.tintColor = UIColor.white
        
        self.navigationItem.setRightBarButtonItems([search_item, message_item, alarm_item], animated: false)
        self.navigationItem.setLeftBarButtonItems([logo_item, title_item], animated: false)
    }
    
    // 로고 터치
    @objc func navi_logo() {
        print("logo")
    }
    
    // 알람 터치
    @objc func navi_alarm() {
        print("alarm")
    }
    
    // 메세지 터치
    @objc func navi_message() {
        print("message")
    }
    
    @objc func navi_search() {
        let vc = self.instanceMainVC(name: "search")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // 키보드 가리기
    func hideKeyboard_tap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    func addToolBar(textField: UITextField, title: String) {
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.tintColor = UIColor.white
        toolbar.barTintColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(barPressed))
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        done.width = UIScreen.main.bounds.width
        toolbar.setItems([done], animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
    }
    
    @objc func barPressed(){
        print("bar pressed")
    }
}


extension UIImage {
    func resizeImage(size: CGSize) -> UIImage {
        let originalSize = self.size
        let ratio: CGFloat = {
            return originalSize.width > originalSize.height ? 1 / (size.width / originalSize.width) :
                1 / (size.height / originalSize.height)
        }()
        
        return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
    }
}

extension UIView {
    func shake(_ duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation]
        shakeGroup.duration = duration
        self.layer.add(shakeGroup, forKey: "shakeIt")
    }
    
    func pushTransition(direction: CATransitionSubtype) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = direction
        animation.duration = 0.5
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }

    
}

extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
}

extension Date {
    var yearsFromNow:   Int {
        return Calendar.current.dateComponents([.year],from: self, to: Date()).year ?? 0
    }
    var monthsFromNow:  Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month  ?? 0
    }
    var weeksFromNow:   Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
    }
    var daysFromNow:    Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    var hoursFromNow:   Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
    }
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
    }
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
    }
    
    var relativeTime: String {
        if yearsFromNow   > 0 {
            return "\(yearsFromNow)년 전"
        }
        if monthsFromNow  > 0 {
            return "\(monthsFromNow)달 전"
        }
        if weeksFromNow   > 0 {
            return "\(weeksFromNow)주 전"
        }
        if daysFromNow    > 0 {
            return daysFromNow == 1 ? "어제": "\(daysFromNow)일 전"
        }
        if hoursFromNow   > 0 {
            return "\(hoursFromNow)시간 전"
        }
        if minutesFromNow > 0 {
            return "\(minutesFromNow)분 전"
        }
        if secondsFromNow >= 0 {
            return secondsFromNow < 10 ? "방금전": "\(secondsFromNow)초 전"
        }

        return ""
    }
}

final class IntrinsicTableView: UITableView {
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
}

// userdefault 데이터
struct data {
    static let isTutorial = "ISTUTORIAL"
    static let isLogin = "ISLOGIN"
    static let isPush = "ISFRISTLOGIN"
    
    struct user {
        static let id = "ID"
        static let token = "TOKEN"
        
        // 로그인 하면서 얻는 정보
        static let email = "EMAIL"
        static let password = "PASSWORD"
        
        // get me 에서 얻음
        static let name = "NAME"
        static let birthday = "BIRTHDAY"
        static let introduce = "INTRODUCE"
        static let gender = "GENDER"
        static let points = "POINTS"
        static let profile = "PROFILE"
    }
}
