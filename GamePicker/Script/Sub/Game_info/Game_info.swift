import UIKit
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class Game_info: UIViewController {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var id : Int = 0
    var comment_arr = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 액티비티 회전 시작
        activity.isHidden = false
        activity.startAnimating()
        
        // id = 0 일때 페이지 벗어나기
        if id == 0 {
            showalert(message: "게임 데이터 로드 실패")
            return
        }
        
        // URL 통신
        get_game_data()
        get_comment_data()
    }

    func get_game_data() {
        let url = "http://gamepicker-api.appspot.com/games/\(id)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseObject {
            (response:DataResponse<Game_info_DTO>) in
            if response.result.isSuccess {
                
                let DTO = response.result.value
                
                print(DTO?.data?.title ?? "No title")
                print(DTO?.data?.developer ?? "No developer")
                print(DTO?.data?.publisher ?? "No publisher")
                print(DTO?.data?.age_rate ?? "No age_rate")
                print(DTO?.data?.summary ?? "No summary")
                print(DTO?.data?.img_link ?? "No img_link")
                print(DTO?.data?.video_link ?? "No video_link")
                print(DTO?.data?.update_date ?? "No update_date")
                print(DTO?.data?.create_date ?? "No create_date")
                
            } else {
                self.showalert(message: "게임 데이터 네트워크 오류")
            }
        }
        
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    func get_comment_data() {
        let url = "http://gamepicker-api.appspot.com/games/\(id)/comments"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    let count = json["data"]["count"].number
                    print("\(count ?? 0)")
                    
                    
                }
            } else {
                self.showalert(message: "코멘트 데이터 네트워크 오류")
            }
        }
    }
    
    // 경고 알림 표시
    func showalert(message : String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(ok)
        self.present(alert,animated: true)
        return
    }
}
