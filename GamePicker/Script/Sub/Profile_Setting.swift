import UIKit

class Profile_Setting: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var Profile_back_img: UIImageView!
    @IBOutlet var Profile_front_img: UIImageView!
    @IBOutlet var Profile_name_txt: UILabel!
    var picture: Int = 0
    let User_data = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let front_image = User_data.object(forKey: "User_front_picture")
        let back_image = User_data.object(forKey: "User_back_picture")
        if front_image != nil { Profile_front_img.image = UIImage(data: front_image as! Data) }
        if back_image != nil { Profile_back_img.image = UIImage(data: back_image as! Data) }
        
        Profile_front_img.layer.masksToBounds = true
        Profile_front_img.layer.cornerRadius = Profile_front_img.frame.size.height/2;
        Profile_front_img.layer.borderWidth = 0.2
        Profile_front_img.layer.borderColor = UIColor.white.cgColor
        Profile_front_img.clipsToBounds = true;
        
        Profile_name_txt.text = User_data.string(forKey: "User_name")
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.back_imageTapped))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.front_imageTapped))
        
        Profile_back_img.addGestureRecognizer(tapGesture1)
        Profile_back_img.isUserInteractionEnabled = true
        Profile_front_img.addGestureRecognizer(tapGesture2)
        Profile_front_img.isUserInteractionEnabled = true
    }
    
    @IBAction func Edit_name(_ sender: Any) { name_edit() }
    @IBAction func Name_touch(_ sender: Any) { name_edit() }
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
            self.set_default()
        }
        let gallery = UIAlertAction(title: "앨범에서 선택", style: .default){
            (result:UIAlertAction) -> Void in
            self.gallery_open()
        }
        let camera = UIAlertAction(title: "사진 촬영", style: .default){
            (result:UIAlertAction) -> Void in
            self.camera_open()
        }
        alert.addAction(cancel)
        alert.addAction(gallery)
        alert.addAction(camera)
        alert.addAction(normal)
        self.present(alert,animated: true)
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
    func set_default() { // 기본값으로
        if self.picture == 1 {
            let img = UIImage(named: "back_default2")
            self.Profile_back_img.image = img
            self.User_data.removeObject(forKey: "User_back_picture")
        } else {
            let img = UIImage(named: "front_default")
            self.Profile_front_img.image = img
            self.User_data.removeObject(forKey: "User_front_picture")
        }
        User_data.synchronize()
    }
    
    func name_edit() { // 이름 수정
        let alert = UIAlertController(title: "닉네임 수정", message: "10자 이내로 입력하새요.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: "수정", style: .default){
            (result:UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            self.Profile_name_txt.text = textField.text
            self.User_data.set(textField.text, forKey: "User_name")
            self.User_data.synchronize()
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextField(configurationHandler: {(tf) in
            tf.placeholder = "닉네임"
            tf.enablesReturnKeyAutomatically = true
            tf.isSecureTextEntry = false
        })
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            // 사진변경 함수
            picker.dismiss(animated: true){() in
            let img = info[UIImagePickerControllerEditedImage] as? UIImage
            let img_data : NSData = UIImagePNGRepresentation(img!)! as NSData
            if self.picture == 1 {
                self.Profile_back_img.image = img
                self.User_data.set(img_data, forKey: "User_back_picture")
            } else {
                self.Profile_front_img.image = img
                self.User_data.set(img_data, forKey: "User_front_picture")
            }
            self.User_data.synchronize()
        }
    }
}
