//
//  First.swift
//  GamePicker
//
//  Created by 정현민 on 29/01/2019.
//  Copyright © 2019 정현민. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class First: UIViewController {
    /* 탭 바 진입 전 확인사항 3가지 */
    
    /* 네트워크 연결 체크 -> 다시 체크 */
    /* 첫 설치 체크 -> 튜토리얼 */
    /* 자동 로그인 체크 -> 로그인 */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        check()
    }
    
    
    /* util functions */
    func start(destination: String) {
        sleep(1)
        
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }

        let vc = self.instanceMainVC(name: destination)
        vc!.view.frame = rootViewController.view.frame
        vc!.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        })
    }
    
    func check() {
        // 네트워크 연결 체크
        switch Connectivity.isConnectedToInternet {
        case true:
            // 네트워크 연결 O
            if UserDefaults.standard.bool(forKey: data.isTutorial) {
                
                // 튜터리얼 진행 O
                if UserDefaults.standard.bool(forKey: data.isLogin) {
                    // 자동 로그인 O
                    // 자동 로그인 실시
                    print("login..")
                    post_login { result in
                        if !result {
                            UserDefaults.standard.set(false, forKey: data.isLogin)
                                
                            print("start with error login..")
                            self.start(destination: "select")
                        } else {
                            print("start with login..")
                            self.start(destination: "tab")
                        }
                    }
                    
                } else {
                    // 자동 로그인 X
                    print("start with logout..")
                    self.start(destination: "select")
                }
                
            } else {
                // 튜토리얼 진행 X
                
                guard let window = UIApplication.shared.keyWindow else { return }
                guard let rootViewController = window.rootViewController else { return }
                
                let vc = self.instanceTutorialVC(name: "MasterVC")
                vc!.view.frame = rootViewController.view.frame
                vc!.view.layoutIfNeeded()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = vc
                })
                
                print("start tutorial")
            }
            
        default:
            // 네트워크 연결 X
            network_alert()
        }
    }
    
    func network_alert() {
        let alert = UIAlertController(title: "네트워크 연결 실패", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "재시도", style: .default) { UIAlertAction in
            self.check()
        }
        alert.addAction(ok) // 0 이면 뒤로가기 추가
        self.present(alert,animated: true)
    }
    
    
    // 로그인 함수
    func post_login(completionHandler: @escaping (Bool) -> Void) {
        let parameters: [String: String] = [
            "email": UserDefaults.standard.string(forKey: data.user.email) ?? "",
            "password": UserDefaults.standard.string(forKey: data.user.password) ?? ""
        ]
        
        Alamofire.request(Api.url + "auth/login", method: .post, parameters: parameters, headers: Api.authorization).responseJSON { (response) in
            let ud = UserDefaults.standard
            guard response.result.isSuccess else {
                self.network_alert()
                return
            }
            
            let json = JSON(response.result.value!)
            if response.response?.statusCode == 200 {
                // User default 에 저장
                ud.set(json["user_id"].intValue, forKey: data.user.id)
                ud.set(json["token"].stringValue, forKey: data.user.token)
                print("login succeed")
                
                // 내정보 get 컴플리션 추가
                print("synchronize..")
                self.get_me(id: json["user_id"].intValue) { result in
                    print("synchronize succeed")
                    if result {
                        // 유저 동기화 성공
                        completionHandler(true)
                        
                    } else {
                        // 유저 동기화 오류
                        custom_alert.red_alert(text: "동기화 실패")
                        completionHandler(false)
                        
                    }
                }
                    
            } else if response.response?.statusCode ?? 0 < 500 {
                custom_alert.red_alert(text: json["message"].stringValue)
                completionHandler(false)
                
            } else {
                custom_alert.red_alert(text: "서버 오류")
                print(response.response?.statusCode ?? 0)
                completionHandler(false)
                
            }
        }
    }
    
    func get_me(id: Int, completionHandler: @escaping (Bool) -> Void) {
        Alamofire.request(Api.url + "me", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                if response.response?.statusCode == 200 {
                    let ud = UserDefaults.standard
                    let user = json["user"].dictionaryValue
                    
                    ud.set(user["points"]?.intValue, forKey: data.user.points)
                    ud.set(user["introduce"]?.string, forKey: data.user.introduce)
                    ud.set(user["gender"]?.string, forKey: data.user.gender)
                    ud.set(user["name"]?.string, forKey: data.user.name)
                    ud.set(user["birthday"]?.string, forKey: data.user.birthday)
                    ud.set(user["email"]?.string, forKey: data.user.email)
                    ud.set(user["profile"]?.string, forKey: data.user.profile)

                    completionHandler(true)
                } else if response.response?.statusCode ?? 0 < 500 {
                    completionHandler(false)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
}
