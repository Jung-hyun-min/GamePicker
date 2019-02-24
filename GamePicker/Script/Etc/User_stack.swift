import UIKit
import Alamofire
import SwiftyJSON
import SwiftMessages

final class User_stack {
    var parent: UIViewController!
    
    
    /* 커뮤니티 버튼 */
    @objc func community(_ sender: User_stack_but) {
        guard let game_id = sender.game_id, let game_title = sender.game_title else {
            custom_alert.red_alert(text: "다시 시도해주세요.")
            return
        }
        
        let child = parent.instanceMainVC(name: "post_list") as? Post_list
        
        child!.game_id = game_id
        child!.game_title = game_title
        child!.category = "games"
        child?.isGame = true
        
        parent.navigationController?.pushViewController(child!, animated: true)
    }
    
    
    /* 찜하기 버튼 */
    @objc func favorite(_ sender: User_stack_but) {
        sender.isEnabled = false
        
        guard let isDone = sender.isDone else {
            custom_alert.red_alert(text: "다시 시도해주세요.")
            return
        }
        
        var method: HTTPMethod?
        
        switch isDone {
        case true: method = .delete
        default: method = .post
        }
        
        request_favorite(sender.game_id!, method!) {
            sender.isEnabled = true
            if method == .post {
                custom_alert.red_alert(text: "찜하기 완료")
                sender.self_image?.image = UIImage(named: "ic_heart_fill")!
                sender.isDone = true
            } else {
                custom_alert.red_alert(text: "찜하기 취소")
                sender.self_image?.image = UIImage(named: "ic_heart_empty")!
                sender.isDone = false
            }
        }
    }
    
    
    /* 평가하기 버튼 */
    @objc func evaluate(_ sender: User_stack_but) {
        let image = sender.game_image ?? UIImage(named: "ic_close")
        
        guard let game_id = sender.game_id, let game_title = sender.game_title else {
            custom_alert.red_alert(text: "다시 시도해주세요.")
            return
        }
        
        custom_alert.score_alert(id: game_id, title: game_title, image: image!) { result in
            self.post_score(game_id, result) {
                guard let pre_score_count = sender.game_score_count else { return }
                guard let pre_score = sender.game_score_value else { return }
                
                var after_score_count: Int {
                    if sender.isDone! {
                        return pre_score_count
                    } else {
                        return pre_score_count + 1
                    }
                }
                
                var sum_score: Double {
                    if sender.isDone! {
                        return pre_score * Double(pre_score_count) - sender.self_myscore_value! + result
                    } else {
                        return pre_score * Double(pre_score_count) + result
                    }
                }
                
                if !sender.isDone! {
                    sender.self_score_count!.pushTransition(direction: .fromBottom)
                }
                
                if pre_score != 0 {
                    if pre_score > result {
                        sender.self_score_value!.pushTransition(direction: .fromTop)
                    } else if pre_score < result {
                        sender.self_score_value!.pushTransition(direction: .fromBottom)
                    }
                }
                
                let score = sum_score / Double(after_score_count)
                
                
                sender.self_score_value!.text = String((round(score * 100)/100))
                sender.self_score_count!.text = String(Int(after_score_count))
                sender.self_myscore?.text = String(result)
                sender.self_myscore_value = result
                sender.game_score_count = after_score_count
                sender.game_score_value = score
                sender.isDone = true
                
                UIView.transition(with: sender.self_myscore_view!, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    sender.self_myscore_view?.isHidden = false
                })
            }
        }
    }
    
    
    /* API functions */
    func request_favorite(_ id: Int, _ method: HTTPMethod, completionHandler: @escaping () -> Void) {
        Alamofire.request(Api.url + "games/\(id)/favor", method: method, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    completionHandler()
                } else if response.response?.statusCode ?? 0 < 500 {
                    custom_alert.red_alert(text: json["message"].stringValue)
                } else {
                    custom_alert.red_alert(text: "서버 오류")
                }
                
            } else {
                custom_alert.red_alert(text: "네트워크 연결 실패")
            }
        }
    }
    
    func post_score(_ id: Int, _ score: Double, completionHandler: @escaping () -> Void) {
        let parameter: [String: Any] = [
            "score": score
        ]

        Alamofire.request(Api.url + "games/\(id)/score", method: .put, parameters: parameter, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    custom_alert.red_alert(text: "평가 완료")
                    completionHandler()
                    
                } else if response.response?.statusCode ?? 0 < 500 {
                    custom_alert.red_alert(text: json["message"].stringValue)
                    
                } else {
                    custom_alert.red_alert(text: "서버 오류")
                    
                }
                
            } else {
                custom_alert.red_alert(text: "네트워크 연결 실패")
                
            }
        }
    }
}


/* 파라미터 클래스 */
final class User_stack_but: UIButton {
    
    var game_title: String?
    var game_image: UIImage?
    var game_id: Int?
    var isDone: Bool?
    
    var game_score_value: Double?
    var game_score_count: Int?
    
    var self_image: UIImageView?
    var self_score_value: UILabel?
    var self_score_count: UILabel?
    
    var self_myscore_value: Double?
    var self_myscore_view: UIView?
    var self_myscore: UILabel?
    
}
