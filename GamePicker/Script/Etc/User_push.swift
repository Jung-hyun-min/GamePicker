//
//  User_push.swift
//  GamePicker
//
//  Created by 정현민 on 21/02/2019.
//  Copyright © 2019 정현민. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


class User_push: UIViewController {
    @IBOutlet var welcome: UILabel!
    @IBOutlet var push_but: UIButton!
    @IBOutlet var start_but: UIButton!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var push_isCheck: Bool = false

    
    override func viewDidLoad() {
        welcome.text = UserDefaults.standard.string(forKey: data.user.name)! + "님, 환영합니다."
    }
    
    @IBAction func push_box(_ sender: Any) {
        if push_isCheck {
            push_isCheck = false
            push_but.setImage(UIImage(named: "ic_check_on"), for: .normal)
        } else {
            push_isCheck = true
            push_but.setImage(UIImage(named: "ic_check_off"), for: .normal)
        }
    }
    
    @IBAction func start(_ sender: Any) {
        indicator.startAnimating()
        if push_isCheck {
            post_push() { result in
                if result {
                    self.indicator.stopAnimating()
                    self.change_rootview()
                }
            }
            
        } else {
            change_rootview()
        }
    }
    
    
    func change_rootview() {
        UserDefaults.standard.set(true, forKey: data.isPush)
        UserDefaults.standard.set(true, forKey: data.isLogin)
        self.view.window?.rootViewController?.dismiss(animated: false) {
            guard let window = UIApplication.shared.keyWindow else { return }
            guard let rootViewController = window.rootViewController else { return }
            
            let vc = self.instanceMainVC(name: "tab")
            vc!.view.frame = rootViewController.view.frame
            vc!.view.layoutIfNeeded()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = vc
            })
        }
    }
    
    func check() {
        /*
        if push_isCheck {
            start_but.isEnabled = true
            start_but.backgroundColor = UIColor.lightGray
        } else {
            start_but.isEnabled = false
            start_but.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
 */
    }
    
    
    func post_push(completionHandler: @escaping (Bool) -> Void) {
        var reg_id: String?

        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                reg_id = result.token
            }
        }
 
        let parameter: [String: String] = [
            "os_type" : "ios",
            "reg_id" : reg_id!
        ]
        
        Alamofire.request(Api.url + "me/push", method: .post, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            if response.result.isFailure {
                self.showalert(message: "서버 응답 오류", can: 0)
                completionHandler(false)
            } else {
                print("push agree succeed")
                completionHandler(true)
            }
        }
    }
}
