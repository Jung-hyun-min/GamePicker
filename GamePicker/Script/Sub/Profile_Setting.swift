import UIKit
import Firebase

class Profile_Setting: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    @IBOutlet var Profile_image: UIImageView!
    @IBOutlet var Back_image: UIImageView!
    @IBOutlet var User_name: UITextField!
    @IBOutlet var User_intro: UITextField!
    
    @IBOutlet var name_limit: UILabel!
    @IBOutlet var intro_limit: UILabel!
    
    var keyboardShown:Bool = false // 키보드 상태 확인
    var originY:CGFloat? // 오브젝트의 기본 위치
    
    var picture: Int = 0
    let User_data = UserDefaults.standard
    
    // 키보드 옵저버 관련
    override func viewWillAppear(_ animated: Bool) { registerForKeyboardNotifications() }
    override func viewWillDisappear(_ animated: Bool) { unregisterForKeyboardNotifications() }
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 프로필 동기화
        Profile_chk()
        
        // 프로필 사진, 배경사진 모양 설정
        Profile_image.layer.masksToBounds = true
        Profile_image.layer.cornerRadius = Profile_image.frame.size.height/2
        Profile_image.layer.borderWidth = 3
        Profile_image.layer.borderColor = UIColor.white.cgColor
        Profile_image.clipsToBounds = true;
        Back_image.layer.masksToBounds = false
        Back_image.layer.shadowOpacity = 0.5
        Back_image.layer.shadowRadius = 15
        Back_image.layer.shadowColor = UIColor.red.cgColor
        Back_image.layer.shadowOffset = CGSize.init(width: 0, height: 8)
        
        User_intro.borderStyle = .none
        User_intro.backgroundColor = UIColor.white
        User_intro.layer.cornerRadius = User_intro.frame.size.height / 2
        User_intro.layer.borderWidth = 0.25
        User_intro.layer.borderColor = UIColor.white.cgColor
        User_intro.layer.shadowOpacity = 1
        User_intro.layer.shadowRadius = 3.0
        User_intro.layer.shadowOffset = CGSize.zero
        User_intro.layer.shadowColor = UIColor.lightGray.cgColor
        var paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: User_intro.frame.height))
        User_intro.leftView = paddingView
        User_intro.leftViewMode = UITextFieldViewMode.always
        
        User_name.borderStyle = .none
        User_name.backgroundColor = UIColor.white
        User_name.layer.cornerRadius = User_name.frame.size.height / 2
        User_name.layer.borderWidth = 0.25
        User_name.layer.borderColor = UIColor.white.cgColor
        User_name.layer.shadowOpacity = 1
        User_name.layer.shadowRadius = 3.0
        User_name.layer.shadowOffset = CGSize.zero
        User_name.layer.shadowColor = UIColor.lightGray.cgColor
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: User_name.frame.height))
        User_name.leftView = paddingView
        User_name.leftViewMode = UITextFieldViewMode.always
        
        // 초기 텍스트 설정
        name_limit.text = "\(User_name.text?.count ?? 0) / 10"
        intro_limit.text = "\(User_intro.text?.count ?? 0) / 30"
        
        //키보드를 제외한 모든곳 탭제스쳐 추가
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        // 이미지 탭 제스쳐 추가
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.back_imageTapped))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.front_imageTapped))
        Back_image.addGestureRecognizer(tapGesture1)
        Profile_image.addGestureRecognizer(tapGesture2)
        Back_image.isUserInteractionEnabled = true
        Profile_image.isUserInteractionEnabled = true
    }
    
    func Profile_chk() { // 화면에 프로필 표시
        if let name = User_data.string(forKey: "User_name") { // 이름
            User_name.text = name
            User_name.placeholder = User_data.string(forKey: "User_name")
        } else {
            User_name.text = "닉네임"
        }
        if let intro = User_data.string(forKey: "User_intro") { // 소개
            if intro == "" {
                User_intro.placeholder = "한줄소개를 입력해 주세요."
            } else {
                User_intro.placeholder = User_data.string(forKey: "User_intro")
                User_intro.text = intro
            }
        } else {
            User_intro.placeholder = " "
        }
        if let front_image = User_data.object(forKey: "User_front_picture") { // 프사
            Profile_image.image = UIImage(data: front_image as! Data)
        } else { Profile_image.image = UIImage(named: "front_default")
        }
        if let back_image = User_data.object(forKey: "User_back_picture") { // 배사
            Back_image.image = UIImage(data: back_image as! Data)
        } else {
            Back_image.image = UIImage(named: "back_default.png")
        }
    }
    // 밑 함수 두개 키보드 제어
    @objc func endEditing() {
        User_intro.resignFirstResponder()
        User_name.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 키보드 화면 올리기 내리기
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 || keyboardShown == true { return }
            UIView.animate(withDuration: 0.33, animations: {
                if self.originY == nil { self.originY = self.view.frame.origin.y }
                self.view.frame.origin.y = self.originY! - keyboardSize.height
            }) { (Bool) in self.keyboardShown = true }
        }
    }
    @objc func keyboardWillHide(note: NSNotification) {
        if keyboardShown == false { return }
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            guard let originY = self.originY else { return }
            self.view.frame.origin.y = originY
        }) { (Bool) in self.keyboardShown = false }
    }
        
    func textFieldShouldClear(_ textField: UITextField) -> Bool { // 클리어
        if textField == User_name { name_limit.text = "0 / 10" }
        else { intro_limit.text = "0 / 30" }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { // 수정완료 저장
        if textField == User_name { // 이름 변경
            if textField.text != "" {
                self.User_data.set(textField.text, forKey: "User_name")
                User_name.placeholder = User_data.string(forKey: "User_name")
            
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() // firebase 전송
                changeRequest?.displayName = textField.text
                changeRequest?.commitChanges { (error) in
                }
            } else {
                textField.text = User_data.string(forKey: "User_name")
                text_alert()
            }
        } else { // 한줄 소개 변경
            self.User_data.set(textField.text, forKey: "User_intro")
            if textField.text != "" {
                User_intro.placeholder = User_data.string(forKey: "User_intro")
            } else {
                User_intro.placeholder = "한줄소개를 입력해 주세요."
            }
        }
        self.User_data.synchronize()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == User_name { // 이름 제한
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            name_limit.text = "\(newLength) / 10"
            return newLength <= 10
        } else { // 한줄 소개 제한
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            if updatedText.count <= 30 {
                intro_limit.text = "\(updatedText.count) / 30"
            }
            return updatedText.count <= 30
        }
    }
    
    func text_alert() { // 최소 1자
        let alert = UIAlertController(title: nil, message: "이름은 필수입력 항목입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.User_name.becomeFirstResponder()
        }
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    @IBAction func Front_touch(_ sender: Any) {
        picture = 2
        show_alert()
    }
    @IBAction func Back_touch(_ sender: Any) {
        picture = 1
        show_alert()
    }
    @objc func back_imageTapped() {
        picture = 1
        show_alert()
    }
    @objc func front_imageTapped() {
        picture = 2
        show_alert()
    }
    
    func show_alert() {
        var alert_title: String = ""
        if picture == 1 { alert_title = "배경 사진" }
        else { alert_title = "프로필 사진" }
        let alert = UIAlertController(title: alert_title, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let normal = UIAlertAction(title: "기본이미지", style: .default){
            (result:UIAlertAction) -> Void in
            // 기본으로 설정
            self.set_default()
        }
        let gallery = UIAlertAction(title: "앨범에서 선택", style: .default){
            (result:UIAlertAction) -> Void in
            // 갤러리 오픈
            self.gallery_open()
        }
        let camera = UIAlertAction(title: "사진 촬영", style: .default){
            (result:UIAlertAction) -> Void in
            // 카메라 설정
            self.camera_open()
        }
        alert.addAction(cancel)
        alert.addAction(gallery)
        alert.addAction(camera)
        alert.addAction(normal)
        self.present(alert,animated: true)
    }
    
    func set_default() { // 기본값으로
        if self.picture == 1 {
            let img = UIImage(named: "back_default")
            self.Back_image.image = img
            self.User_data.removeObject(forKey: "User_back_picture")
        } else {
            let img = UIImage(named: "front_default")
            self.Profile_image.image = img
            self.User_data.removeObject(forKey: "User_front_picture")
        }
        User_data.synchronize()
    }
    
    func camera_open() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    func gallery_open() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { // 사진변경 함수
            picker.dismiss(animated: true){() in
            let img = info[UIImagePickerControllerEditedImage] as? UIImage
            let img_data : NSData = UIImagePNGRepresentation(img!)! as NSData
            if self.picture == 1 {
                self.Back_image.image = img
                self.User_data.set(img_data, forKey: "User_back_picture")
            } else {
                self.Profile_image.image = img
                self.User_data.set(img_data, forKey: "User_front_picture")
            }
            self.User_data.synchronize()
        }
    }
}
