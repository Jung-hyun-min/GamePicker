import UIKit
import Alamofire
import SwiftyJSON

class Game_info: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet var table: UITableView!
    // 유저 디폴트 변수 선언 후 사용
    let User_data = UserDefaults.standard
    // api prefix
    let api = Api_url()
    // 게임 아이디
    var id : Int = 0
    // 게임 변수
    var game_title : String?
    var game_image_string : String?
    // 댓글 저장 배열
    lazy var comment : [Comment_VO] = {
        var datalist = [Comment_VO]()
        return datalist
    }()
    // 댓글 입력 텍스트
    var comment_text : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // id = 0 일때 페이지 벗어나기
        if id == 0 {
            showalert(message: "게임 데이터 로드 실패",can: 0)
            return
        }
        
        // 댓글 초기화
        comment.removeAll()
        
        // URL 통신
        get_game()
        get_game_comment()
    }
    
    // 섹션별 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { // info1
            return 250
        }
        if indexPath.section == 1 { // info2
            return 150
        }
        if indexPath.section == 2 { // 비디오
            return 100
        }
        if indexPath.section == 3 { // 댓글 작성
            return 50
        } else {
            let row = comment[indexPath.row]
            let height = CGFloat(70 + ((row.value?.count)! / 30) * 20)
            return height
        }
    }
    
    // 섹션 number
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
 
    // numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // 게임 이미지
            return 1
        }
        if section == 1 { // 게임 정보
            return 1
        }
        if section == 2 { // 비디오
            return 1
        }
        if section == 3 { // 댓글 작성
            return 1
        } else { // 댓글
            return comment.count
        }
    }
    
    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // info1
        if indexPath.section == 0 {
            let info1 = tableView.dequeueReusableCell(withIdentifier: "game_info_1", for: indexPath) as! Game_info_cell_1
            
            // 버튼에 태그 지정
            info1.like.tag = 0
            info1.rate.tag = 1
            info1.commuity.tag = 2
            
            // 텍스트, 이미지 처리
            info1.game_title.text = self.game_title
            info1.game_rate.text = "평균 평점 : 0.99 (1명)"
            
            return info1
        }
        
        if indexPath.section == 1 {
            let info2 = tableView.dequeueReusableCell(withIdentifier: "game_info_2", for: indexPath) as! Game_info_cell_2
        
            return info2
        }
        
        if indexPath.section == 2 {
            let video = tableView.dequeueReusableCell(withIdentifier: "game_viedo", for: indexPath) as! Game_video_cell
            
            
            return video
        }
        
        if indexPath.section == 3{
            let write = tableView.dequeueReusableCell(withIdentifier: "comment_write", for: indexPath) as! Comment_write_cell
            comment_text = ""
            write.input.addTarget(self, action: #selector(self.write_game_comment), for: .touchUpInside)
            write.textfield.text = ""
            return write
        }
            
        else {
            let comment = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
            let row = self.comment[indexPath.row]
            
            comment.name.text = row.name
            comment.value.text = row.value
            comment.date.text = row.update_date
            
            comment.more.tag = row.id ?? 0
            comment.more.addTarget(self, action: #selector(self.comment_alert), for: .touchUpInside)
            
            return comment
        }
    }

    // 게임 정보 조회
    func get_game() {
        let url = api.pre + "games/\(id)"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    
                    self.game_title = json["data"]["title"].stringValue
                    self.game_image_string = json["data"]["img_link"].stringValue
                    
                    self.table.reloadData()
                }
            } else {
                self.showalert(message: "게임 데이터 조회 네트워크 오류",can: 0)
            }
        }
    }
    
    // 게임 댓글 조회
    func get_game_comment() {
        let url = api.pre + "games/\(id)/comments"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    let count = json["data"]["count"].intValue
                    
                    print("\(count) comments in this game")
                    
                    for (_,subJson):(String, JSON) in json["data"]["comments"] {
                        let id = subJson["id"].intValue
                        let value = subJson["value"].stringValue
                        let update_date = subJson["update_date"].stringValue
                        let name = subJson["name"].stringValue
                        
                        let com = Comment_VO()
                        
                        com.id = id
                        com.value = value
                        com.update_date = update_date
                        com.name = name
                        
                        self.comment.append(com)
                    }
                    self.table.reloadData()
                } else {
                    self.showalert(message: "코멘트 데이터 조회 API 오류",can: 0)
                }
            } else {
                self.showalert(message: "코멘트 데이터 조회 네트워크(time) 오류",can: 0)
            }
        }
    }
    
    // 게임 댓글 작성
    @objc func write_game_comment() {
        if comment_text == "" || comment_text == nil {
            showalert(message: "내용을 입력해주세요.", can: 1)
            return
        }
        
        let params: [String: String] = ["value" : comment_text ?? ""]
        let heads: [String: String] = ["x-access-token" : User_data.string(forKey: "User_token") ?? ""]
        
        let url = api.pre + "games/\(id)/comments"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print("댓글 입력 완료")
                    print(response.result.value!)
                    
                    self.comment.removeAll()
                    
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 입력 오류\n" + json["data"].stringValue,can: 0)
                }
            } else {
                self.showalert(message: "코멘트 데이터 작성 네트워크 오류",can: 0)
            }
        }
    }
    
    // 게임 댓글 삭제
    func delete_game_comment(comment_id : Int) {
        print("\(comment_id)")
        print("\(id)")
        let heads: [String: String] = [
            "x-access-token" : User_data.string(forKey: "User_token") ?? ""
        ]
        
        let url = api.pre + "games/\(id)/comments/\(comment_id)"
        
        Alamofire.request(url, method: .delete, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                print("delete")
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print("댓삭 완료")
                    print(response.result.value!)
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 삭제 오류\n" + json["data"].stringValue,can: 0)
                }
            } else {
                self.showalert(message: "comment data time error\n" + response.result.description,can: 0)
            }
        }
    }
    
    @objc func comment_alert(sender : UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) {
            (result:UIAlertAction) -> Void in
            self.delete_game_comment(comment_id: sender.tag)
        }
        let singo = UIAlertAction(title: "신고", style: .default) {
            (result:UIAlertAction) -> Void in
            self.showalert(message: "준비중인 기능입니다",can: 1)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(delete)
        alert.addAction(singo)
        alert.addAction(cancel)
        self.present(alert,animated: true)
        return
    }
    
    // 경고 알림 표시
    func showalert(message : String, can : Int) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        // 뒤로가기
        if can == 0 {
            alert.addAction(ok)
        } else {
            alert.addAction(cancel)
        }
        self.present(alert,animated: true)
        return
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 1 {
            comment_text = textField.text!
            let text = comment_text?.prefix(range.location)
            comment_text = String(text ?? "")
            print(comment_text!)
        } else {
            comment_text = textField.text! + string
            print(textField.text! + string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        write_game_comment()
        return true
    }
    
}
