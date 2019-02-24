//
//  User_message.swift
//  GamePicker
//
//  Created by 정현민 on 20/02/2019.
//  Copyright © 2019 정현민. All rights reserved.
//

import UIKit

class User_message {
    var message_view: UIView?
    var main_title: UILabel?
    var sub_title: UILabel?
    var yes_but: UIButton?
    var no_but: UIButton?
    
    
    @objc func response_yes() {
        custom_alert.red_alert(text: "응답 감사합니다")
        hide_view()
    }
    
    @objc func response_no() {
        custom_alert.red_alert(text: "알겠습니다.")
        hide_view()
    }
    
    @objc func hide_view() {
        UIView.animate(withDuration: Double(0.3), animations: {
            self.message_view!.isHidden = true
        })
    }
    
    
    func main_message() {
        let randomFunc = [self.message_1, self.message_2, self.message_4]
        return randomFunc.randomElement()!()
    }
    
    func community_message() {
        let randomFunc = [self.message_2, self.message_3, self.message_5]
        return randomFunc.randomElement()!()
    }
    
    
    private func message_1() {
        let user_name = UserDefaults.standard.string(forKey: data.user.name)
        
        main_title?.text = user_name! + "님, 안녕하세요!"
        sub_title?.text = "아래의 추천게임을 즐겨보세요."
    }
    
    private func message_2() {
        let user_name = UserDefaults.standard.string(forKey: data.user.name)
        
        main_title?.text = user_name! + "님, 찾는 게임 있어요?"
        sub_title?.text = "우측 상단 검색버튼을 클릭해보세요."
    }
    
    private func message_3() {
        let user_name = UserDefaults.standard.string(forKey: data.user.name)
        
        main_title?.text = user_name! + "님, 플레이중인 게임의 커뮤니티를 들어가보세요!"
        sub_title?.text = "함께 게임의 이야기를 나눠보세요."
    }
    
    private func message_4() {
        let user_name = UserDefaults.standard.string(forKey: data.user.name)
        
        main_title?.text = user_name! + "님, 게임을 평가해주세요!"
        sub_title?.text = "게임추천의 정확도가 높아집니다."
    }
    
    private func message_5() {
        let user_name = UserDefaults.standard.string(forKey: data.user.name)
        
        main_title?.text = user_name! + "님, 혼자 플레이하고 계신가요?"
        sub_title?.text = "아래의 커뮤니티를 통해 함께 게임하세요."
    }
}
