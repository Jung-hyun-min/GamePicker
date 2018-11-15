import UIKit

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
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
