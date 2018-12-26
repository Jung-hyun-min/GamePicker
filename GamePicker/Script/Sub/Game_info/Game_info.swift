import UIKit
import Alamofire
import SwiftyJSON
import youtube_ios_player_helper

class Game_info: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet var table: UITableView!
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var Game_imgview: UIImageView!
    @IBOutlet var Game_namelabel: UILabel!
    
    // 유저 디폴트 변수 선언 후 사용
    let User_data = UserDefaults.standard
    // api prefix
    let api = Api_url()
    // 게임 아이디
    var id : Int = 0
    // 게임 변수
    var game_title : String = ""
    var game_image_url : String = ""
    var game_video_url : String = ""
    var game_summary : String = ""
    // 댓글 저장 배열
    lazy var comment : [Comment_VO] = {
        var datalist = [Comment_VO]()
        return datalist
    }()
    // 댓글 관련 변수
    var comment_number : Int = 0
    var comment_text : String = ""
    // 게임 평가 점수
    var rating : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.isHidden = true
        activity.startAnimating()
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
            return 30
        }
        if indexPath.section == 1 { // info2
            return UITableView.automaticDimension
        }
        if indexPath.section == 2 { // 비디오
            let height = UIScreen.main.bounds.size.width*9/16
            return height + 45
        }
        if indexPath.section == 3 { // 댓글 작성
            return 95
        } else {
            return UITableView.automaticDimension
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
            info1.like.tag = id
            info1.rate.tag = id
            info1.commuity.tag = id
            
            info1.like.addTarget(self, action: #selector(self.like), for: .touchUpInside)
            info1.rate.addTarget(self, action: #selector(self.rate), for: .touchUpInside)
            info1.commuity.addTarget(self, action: #selector(self.community), for: .touchUpInside)
            
            // 텍스트, 이미지 처리
            
            // info1.game_title.text = self.game_title
            //info1.game_rate.text = "평균 평점 : 0.99 (1명)"
            // 이미지 비동기 처리
            /*
            if let url = URL(string :game_image_url) {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        info1.game_image.image = UIImage(data: data)
                    }
                }
            }
 */
            return info1
        }
        // info2
        if indexPath.section == 1 {
            let info2 = tableView.dequeueReusableCell(withIdentifier: "game_info_2", for: indexPath) as! Game_info_cell_2
            
            info2.game_summary.text = game_summary
            
            return info2
        }
        // 비디오
        if indexPath.section == 2 {
            let video = tableView.dequeueReusableCell(withIdentifier: "game_viedo", for: indexPath) as! Game_video_cell
            
            let ID = String(game_video_url.suffix(11))
            if video.game_video.currentTime() == 0 {
                video.game_video.load(withVideoId: ID, playerVars: ["playsinline":"1"])
            }
            
            return video
        }
        // 댓글 작성
        if indexPath.section == 3 {
            let write = tableView.dequeueReusableCell(withIdentifier: "comment_write", for: indexPath) as! Comment_write_cell
            comment_text = ""
            write.comment_num.text = "\(comment_number)"
            write.input.addTarget(self, action: #selector(self.write_game_comment), for: .touchUpInside)
            write.textfield.text = ""
            return write
        }
        // 댓글
        else {
            let comment = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! Comment_cell
            let row = self.comment[indexPath.row]
            
            comment.name.text = row.name
            comment.value.text = row.value
            comment.date.text = row.update_date
            
            comment.more.tag = row.id ?? 0
            comment.more.addTarget(self, action: #selector(self.comment_alert_1), for: .touchUpInside)
            
            comment.like.tag = row.id ?? 0
            comment.dislike.tag = row.id ?? 0
            
            comment.like.addTarget(self, action: #selector(self.comment_like), for: .touchUpInside)
            comment.dislike.addTarget(self, action: #selector(self.comment_dislike), for: .touchUpInside)
            return comment
        }
    }
    
    @objc func comment_like(sender : UIButton) {
        print("\(sender.tag) + like")
    }
    @objc func comment_dislike(sender : UIButton) {
        print("\(sender.tag) + dislike")
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
                    self.game_image_url = json["data"]["img_link"].stringValue
                    self.game_video_url = json["data"]["video_link"].stringValue
                    self.game_summary = json["data"]["summary"].stringValue
                    
                    
                    self.Game_namelabel.text = self.game_title
                    
                    if let url = URL(string :self.game_image_url) {
                        self.getData(from: url) { data, response, error in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async() {
                                self.Game_imgview.image = UIImage(data: data)
                            }
                        }
                    }
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
                    self.comment_number = json["data"]["count"].intValue

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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.table.isHidden = false
                        self.activity.stopAnimating()
                        self.table.reloadData()
                    })
 
                } else {
                    self.showalert(message: "코멘트 데이터 조회 API 오류",can: 0)
                }
            } else {
                self.showalert(message: "코멘트 데이터 조회 네트워크(time) 오류",can: 0)
            }
        }
    }
    
    // 게임 추천
    func rate_game() {
        if rating == 0 {
            print("rate error")
            return
        }
        print("진입")
        
        let params: [String: Double] = ["value" : rating]
        let heads: [String: String] = ["x-access-token" : User_data.string(forKey: "User_token") ?? ""]
        
        let url = api.pre + "games/\(id)/rates"
        Alamofire.request(url, method: .post, parameters: params, headers: heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print("추천 성공")
                } else {
                    self.showalert(message: "평가 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: "평가 작성 네트워크 오류",can: 0)
            }
            
        }
    }
    
    // 게임 댓글 작성
    @objc func write_game_comment() {
        if comment_text == ""{
            showalert(message: "내용을 입력해주세요.", can: 1)
            return
        }
        
        let params: [String: String] = ["value" : comment_text]
        let heads: [String: String] = ["x-access-token" : User_data.string(forKey: "User_token") ?? ""]
        
        let url = api.pre + "games/\(id)/comments"
        Alamofire.request(url, method: .post, parameters: params, headers: heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 입력 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: "코멘트 데이터 작성 네트워크 오류",can: 0)
            }
        }
    }
    
    // 게임 댓글 삭제
    func delete_game_comment(comment_id : Int) {
        let heads: [String : String] = [
            "x-access-token" : User_data.string(forKey: "User_token") ?? ""
        ]
        let url = api.pre + "games/\(id)/comments/\(comment_id)"
        
        Alamofire.request(url, method: .delete, headers : heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                print(json)
                if status == "success" {
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 삭제 오류\n" + json["data"].stringValue,can: 1)
                }
            } else {
                self.showalert(message: response.result.debugDescription,can: 0)
            }
        }
    }
    
    // 게임 댓글 수정
    func modify_game_comment(comment_id : Int,text : String) {
        let heads: [String: String] = [
            "x-access-token" : User_data.string(forKey: "User_token") ?? ""
        ]
        
        let params: [String: String] = [
            "value" : text
        ]
        
        let url = api.pre + "games/\(id)/comments/\(comment_id)"
        
        Alamofire.request(url, method: .put, parameters: params, headers: heads).responseJSON {(response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let status = json["status"].stringValue
                if status == "success" {
                    print(response.result.value!)
                    self.comment.removeAll()
                    self.get_game_comment()
                } else {
                    self.showalert(message: "댓글 수정 오류\n" + json["data"].stringValue,can: 0)
                }
            } else {
                self.showalert(message: "comment data time error\n" + response.result.description,can: 0)
            }
        }
    }
    
    @objc func comment_alert_1(sender : UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "삭제", style: .default) {
            (result:UIAlertAction) -> Void in
            self.comment_alert_2(id: sender.tag,which: 1)
        }
        let modify = UIAlertAction(title: "수정", style: .default) {
            (result:UIAlertAction) -> Void in
            self.comment_alert_2(id : sender.tag,which: 2)
        }
        let singo = UIAlertAction(title: "신고", style: .default) {
            (result:UIAlertAction) -> Void in
            self.showalert(message: "준비중인 기능입니다",can: 1)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(delete)
        alert.addAction(modify)
        alert.addAction(singo)
        alert.addAction(cancel)
        self.present(alert,animated: true)
        
        return
    }
    
    func comment_alert_2(id : Int, which : Int) {
        var message : String = ""
        
        if which == 1 {
            message = "댓글을 삭제하십니까?"
        } else {
            message = ""
        }
        
        let alert = UIAlertController(title: "댓글", message: message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.delete_game_comment(comment_id: id)
        }
        
        let modify = UIAlertAction(title: "수정", style: .destructive) {
            (result:UIAlertAction) -> Void in
            let modify_field = alert.textFields![0]
            
            if modify_field.text == "" {
                alert.message = "수정값이 공백입니다."
            } else {
                self.modify_game_comment(comment_id: id,text: modify_field.text ?? "")
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        if which == 1 {
            alert.addAction(delete)
        } else {
            alert.addTextField { (field) in
                field.placeholder = "수정할 댓글을 입력하세요."
            }
            alert.addAction(modify)
        }
        
        alert.addAction(cancel)
        self.present(alert,animated: true)
        return
    }
    // 게임 댓글 작성
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 1 {
            comment_text = String(textField.text!.prefix(range.location))
        } else {
            comment_text = textField.text! + string
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        write_game_comment()
        return true
    }
    
    @objc func like(sender: UIButton) {
        self.performSegue(withIdentifier: "Post", sender: sender.tag)
    }
    
    @objc func rate(sender: UIButton) {
        
    }
    
    @objc func community(sender: UIButton) {
        self.performSegue(withIdentifier: "Post", sender: sender.tag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Post
        param.game_id = sender as! Int
        param.game_title = game_title
    }
    
}
