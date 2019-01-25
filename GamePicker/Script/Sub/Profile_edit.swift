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

class Profile_edit : UIViewController {
    @IBOutlet var profile_img: UIImageView! // 프로필 이미지
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var name_field: UITextField!
    @IBOutlet var intro_field: UITextField!
    @IBOutlet var date_field: UITextField!
    @IBOutlet var gender_segment: UISegmentedControl!
    
    private var datepicker: UIDatePicker?
    
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datepicker = UIDatePicker()
        datepicker?.datePickerMode = .date
        datepicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datepicker?.locale = Locale(identifier: "ko")
        date_field.inputView = datepicker
        
        profile_img.layer.cornerRadius = UIScreen.main.bounds.width/6
        
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
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-mm-dd"
        date_field.text = dateFormatter.string(from: datePicker.date)
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
    
    @IBAction func gender(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "성별을 수정하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.indicator.startAnimating()
            self.put_edit()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert,animated: true)
    }
    
    func put_edit() {
        var gender: String?
        if gender_segment.selectedSegmentIndex == 0 { gender = "M" }
        else { gender = "W" }
        
        let parameter: [String: Any] = [
            "name" : name_field.text!,
            "introduce" : intro_field.text!,
            "birthday" : date_field.text!,
            "gender" : gender ?? ""
        ]
        
        let header: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: data.user.token) ?? ""
        ]
        
        let id: String = ud.string(forKey: data.user.id) ?? ""
            
        Alamofire.request(Api.url + "users/\(id)", method: .put, parameters: parameter, headers: header).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    self.indicator.stopAnimating()
                    
                    self.ud.set(self.name_field.text!, forKey: data.user.name)
                    self.ud.set(self.date_field.text!, forKey: data.user.birthday)
                    self.ud.set(self.intro_field.text!, forKey: data.user.introduce)
                    self.ud.set(gender, forKey: data.user.gender)
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.showalert(message: json["message"].stringValue, can: 0)
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
            } else {
                print(response.error.debugDescription)
                self.showalert(message: "서버 응답 오류", can: 0)
            }
        }
    }
    
    func get_name_isOverlap(completionHandler : @escaping (Bool) -> Void ) {
        let urlstr = Api.url + "users?name=" + name_field.text!
        let encoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URL(string: encoded)!).responseJSON { (response) in
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
                self.showalert(message: "서버 응답 오류", can: 1)
            }
        }
    }
    
}
