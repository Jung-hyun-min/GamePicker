import UIKit
import Firebase
import FBSDKCoreKit

class Setting: UIViewController {
    @IBOutlet var Profile_image: UIImageView! // 프로필 사진
    @IBOutlet var Back_image: UIImageView!    // 배경사진
    @IBOutlet var User_name: UILabel!         // 이름
    @IBOutlet var User_intro: UILabel! // 소개
    
    var User_ID: String = ""
    
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //동기화
        Profile_chk()
        
        Profile_image.layer.masksToBounds = true
        Profile_image.layer.cornerRadius  = Profile_image.frame.size.height/2;
        Profile_image.layer.borderWidth   = 3
        Profile_image.layer.borderColor   = UIColor.white.cgColor
        Back_image.layer.cornerRadius  = 5
        Back_image.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        
        // 이미지 탭제스쳐 추가
        let tapGesture_back  = UITapGestureRecognizer(target: self, action: #selector(self.Edit))
        let tapGesture_front = UITapGestureRecognizer(target: self, action: #selector(self.Edit))
        Back_image.addGestureRecognizer(tapGesture_back)
        Profile_image.addGestureRecognizer(tapGesture_front)
        Back_image.isUserInteractionEnabled = true
        Profile_image.isUserInteractionEnabled = true
    }
    
    // Apper 프로필 체크
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.Profile_chk()
        })
    }
    
    func Profile_chk() { // 화면에 프로필 표시
        if let name = User_data.string(forKey: "User_name") { // 이름
            User_name.text = name
        } else {
            User_name.text = "닉네임"
        }
        if let intro = User_data.string(forKey: "User_introduce") { // 소개
            if intro == "" {
                User_intro.text = "한줄소개를 입력해 주세요."
            } else {
                User_intro.text = intro
            }
        } else {
            User_intro.text = "한줄소개를 입력해 주세요."
        }
        
        if let front_image = User_data.object(forKey: "User_front_picture") { // 프사
            Profile_image.image = UIImage(data: front_image as! Data)
        } else {
            Profile_image.image = UIImage(named: "front_default")
        }
        if let back_image = User_data.object(forKey: "User_back_picture") { // 배사
            Back_image.image = UIImage(data: back_image as! Data)
        } else {
            Back_image.image = UIImage(named: "back_default.png")
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
    
    // 로그아웃 버튼
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "알림", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "확인", style: .destructive) {
            (result:UIAlertAction) -> Void in
            do {
                UserDefaults.standard.set(false, forKey: "login")
                self.delete_userdata()
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "Logout", sender: self)
            }
            catch  { }
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
}
