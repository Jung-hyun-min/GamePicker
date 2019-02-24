//
//  Profile_edit.swift
//  GamePicker
//
//  Created by 정현민 on 20/01/2019.
//  Copyright © 2019 정현민. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Carte

class Profile_edit: UIViewController,UITextFieldDelegate {
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var profile_image: UIImageView! // 프로필 이미지
    @IBOutlet var name_field: UITextField!
    @IBOutlet var intro_field: UITextField!
    @IBOutlet var date_field: UITextField!
    @IBOutlet var gender_segment: UISegmentedControl!
    
    private var datepicker: UIDatePicker?
    
    let ud = UserDefaults.standard
    
    let picturepicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturepicker.delegate = self
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        datepicker = UIDatePicker()
        datepicker?.datePickerMode = .date
        datepicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        date_field.inputView = datepicker
        
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileChange))
        profile_image.addGestureRecognizer(recognizer)
        
        profile_image.layer.cornerRadius = UIScreen.main.bounds.width/6
        
        // 텍스트 필드 툴바 추가
        addToolBar(textField: name_field, title: "수정")
        addToolBar(textField: intro_field, title: "수정")
        addToolBar(textField: date_field, title: "수정")
        
        hideKeyboard_tap()
        
        // 초기 플레이스 홀더 지정
        name_field.text = ud.string(forKey: data.user.name)
        intro_field.placeholder = ud.string(forKey: data.user.introduce)
        date_field.text = String(ud.string(forKey: data.user.birthday)!.prefix(10))
        
        // 성별 세그먼트 값 초기 설정
        switch ud.string(forKey: data.user.gender) {
            case "M": gender_segment.selectedSegmentIndex = 0
            case "W": gender_segment.selectedSegmentIndex = 1
            default: break
        }
    }
    
    override func barPressed() {
        view.endEditing(true)
        if name_field.text!.isEmpty {
            showalert(message: "이름 비었슴(임시)", can: 1)
        } else {
            get_name_isOverlap() { result in
                if result {
                    self.showalert(message: "이름중복(임시)", can: 1)
                } else {
                    self.indicator.startAnimating()
                    self.put_edit()
                }
            }
        }
    }
    
    
    // 성병 바꾸기
    @IBAction func gender(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "성별을 수정하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { UIAlertAction in
            self.indicator.startAnimating()
            self.put_edit()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
    
    @IBAction func license(_ sender: Any) {
        let carteViewController = CarteViewController()
        self.navigationController?.pushViewController(carteViewController, animated: true)
    }
    
    
    // 프로필 바꾸기
    @objc func profileChange() {
        picture_alert()
    }
    
    // 생일 바꾸기
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-mm-dd"
        date_field.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    func picture_alert() {
        let alert = UIAlertController(title: "프로필 사진", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let normal = UIAlertAction(title: "기본이미지", style: .default){ _ in
            self.delete_picture()
        }
        let gallery = UIAlertAction(title: "앨범에서 선택", style: .default){ _ in
            self.set_gallery() // 갤러리 오픈
        }
        let camera = UIAlertAction(title: "사진 촬영", style: .default){ _ in
            self.set_camera() // 카메라 설정
        }
        
        alert.addAction(cancel)
        alert.addAction(gallery)
        alert.addAction(camera)
        alert.addAction(normal)
        
        self.present(alert,animated: true)
    }

    func set_gallery() {
        picturepicker.sourceType = .photoLibrary
        picturepicker.allowsEditing = true
        present(picturepicker, animated: true)
    }
    
    func set_camera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picturepicker.sourceType = .camera
            picturepicker.allowsEditing = true
            present(picturepicker, animated: false, completion: nil)
        } else {
            print("Camera not available")
        }
        
    }
    
    
    /* api request */
    func put_edit() {
        var gender: String?
        if gender_segment.selectedSegmentIndex == 0 { gender = "M" }
        else { gender = "W" }
        
        let parameter: [String: Any] = [
            "name": name_field.text!,
            "introduce": intro_field.text!,
            "birthday": date_field.text!,
            "gender": gender ?? ""
        ]
        
        let id: String = ud.string(forKey: data.user.id) ?? ""
            
        Alamofire.request(Api.url + "users/\(id)", method: .put, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                switch response.response?.statusCode ?? 0 {
                case 204: print("user edit succesed")
                    self.indicator.stopAnimating()
                
                    self.ud.set(self.name_field.text!, forKey: data.user.name)
                    self.ud.set(self.date_field.text!, forKey: data.user.birthday)
                    self.ud.set(self.intro_field.text!, forKey: data.user.introduce)
                    self.ud.set(gender, forKey: data.user.gender)
                    
                case ...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
            }
            
            response.result.ifFailure {
                // 실페
                print(response.error.debugDescription)
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
            
        }
    }
    
    func get_name_isOverlap(completionHandler: @escaping (Bool) -> Void ) {
        let urlstr = Api.url + "users?name=" + name_field.text!
        let encoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URL(string: encoded)!, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? "")
                if response.response?.statusCode == 200 {
                    let arr = json["users"].arrayValue
                    if arr.count == 1 { completionHandler(true) }
                    else { completionHandler(false) }
                } else {
                    self.showalert(message: "서버 오류", can: 1)
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 1)
            }
        }
    }
    
    func post_picture(_ imageURL: URL) {
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageURL, withName: "profile")
        }, usingThreshold: UInt64.init(), to: Api.url + "me/profile", method: .post, headers: Api.authorization) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
            
                upload.responseJSON { response in
                    if let result = response.result.value {
                        let json = JSON(result)
                        print(json)
                        print(response.response?.statusCode ?? 0)
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        
    }
    
    func delete_picture() {
        Alamofire.request(Api.url + "me/profile", method: .delete, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                if response.response?.statusCode == 204 {
                    print("delete picture succeed")
                    self.profile_image.image = UIImage(named: "ic_profile")
                }
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }

}

extension Profile_edit: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL: URL = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
        post_picture(imageURL)
        dismiss(animated: true, completion: nil)
    }
}
