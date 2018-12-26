import UIKit

class Api_url {
    let pre = "http://api.gamepicker.me/"
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func showalert(message : String, can : Int) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        // 뒤로가기
        if can == 0 { // 0 이면 뒤로가기 추가
            alert.addAction(ok)
        } else { // 1 이면 뒤로 가기 없음
            alert.addAction(cancel)
        }
        self.present(alert,animated: true)
        return
    }
    
    // 유저 디포트 삭제
    func delete_userdata() {
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
    
    func navigation_icon() {
        let logo = UIImage(named: "img_logo_thumb")!
        let alarm = UIImage(named: "ic_alarm")!
        let message = UIImage(named: "ic_message")!
        let search = UIImage(named: "ic_search")!
        
        let logo_but: UIButton = UIButton.init(type: .custom)
        logo_but.setImage(logo, for: UIControl.State.normal)
        logo_but.addTarget(self, action: #selector(self.navi_logo), for: UIControl.Event.touchUpInside)
        logo_but.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let logo_item = UIBarButtonItem(customView: logo_but)
        
        let title_txt: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 380, height: 21))
        title_txt.text = "GAMEPICKER"
        title_txt.textColor = UIColor.white
        if UIScreen.main.bounds.height <= 568 {
            title_txt.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            title_txt.font = UIFont.boldSystemFont(ofSize: 21)
        }
        title_txt.textAlignment = .center
        let title_item = UIBarButtonItem(customView: title_txt)
        
        let alarm_but: UIButton = UIButton.init(type: .custom)
        alarm_but.setImage(alarm, for: UIControl.State.normal)
        alarm_but.addTarget(self, action: #selector(self.navi_alarm), for: UIControl.Event.touchUpInside)
        alarm_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let alarm_item = UIBarButtonItem(customView: alarm_but)
        
        let message_but: UIButton = UIButton.init(type: .custom)
        message_but.setImage(message, for: UIControl.State.normal)
        message_but.addTarget(self, action: #selector(self.navi_message), for: UIControl.Event.touchUpInside)
        message_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let message_item = UIBarButtonItem(customView: message_but)
        
        let search_but: UIButton = UIButton.init(type: .custom)
        search_but.setImage(search, for: UIControl.State.normal)
        search_but.addTarget(self, action: #selector(self.navi_search), for: UIControl.Event.touchUpInside)
        search_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let search_item = UIBarButtonItem(customView: search_but)
        search_item.tintColor = UIColor.white
        
        self.navigationItem.setRightBarButtonItems([search_item, message_item, alarm_item], animated: false)
        self.navigationItem.setLeftBarButtonItems([logo_item, title_item], animated: false)
    }
    @objc func navi_logo() {
        print("logo")
    }
    
    @objc func navi_alarm() {
        print("alarm")
    }
    
    @objc func navi_message() {
        print("message")
    }
    
    @objc func navi_search() {
        print("search")
        performSegue(withIdentifier: "search", sender: self)
    }
    
}
