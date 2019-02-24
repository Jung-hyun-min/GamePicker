//
//  User_game.swift
//  GamePicker
//
//  Created by 정현민 on 16/02/2019.
//  Copyright © 2019 정현민. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cosmos
import Kingfisher


class User_game: UIViewController {
    @IBOutlet var user_game_table: UITableView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var which: String?
    
    var user_game_arr = [User_game_VO]() // 게시글 저장 배열
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
        switch which {
        case "favor": navigationItem.title = "내가 찜한 게임"
        case "score": navigationItem.title = "내가 평가한 게임"
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        user_game_table.isHidden = true
        get_user_game()
    }
    
    func get_user_game() {
        guard let user_id = UserDefaults.standard.string(forKey: data.user.id) else { return }
        
        Alamofire.request(Api.url + "users/\(user_id)/games/\(which!)", headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                self.user_game_arr.removeAll()
                switch response.response?.statusCode ?? 0 {
                case 200:
                    let user_games = json[self.which! + "s"].arrayValue
                    print(user_games)
                    
                    for subJson: JSON in user_games {
                        let user_game = User_game_VO()
                        
                        user_game.game_title = subJson["title"].stringValue
                        user_game.game_id    = subJson["game_id"].intValue
                        user_game.game_score = subJson["score"].doubleValue
                        user_game.game_image_url = subJson["game_image"].stringValue
                        
                        self.user_game_arr.append(user_game)
                    }
                    self.user_game_table.isHidden = false
                    self.indicator.stopAnimating()
                    self.user_game_table.reloadData()
                    
                case 0...500: self.showalert(message: json["message"].stringValue, can: 0)
                default: self.showalert(message: "서버 오류", can: 0)
                }
                
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}


extension User_game: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user_game_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user_game_cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! User_game_cell
        let row = self.user_game_arr[indexPath.row]
        
        if which == "score" {
            user_game_cell.score.isHidden = false
            user_game_cell.score.rating = row.game_score!
            
        } else {
            user_game_cell.score.isHidden = true
        }
        
        user_game_cell.title.text = row.game_title
        
        user_game_cell.thumbnail.kf.setImage(
            with: URL(string: row.game_image_url!),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 110, height: 80))),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
                ])
        
        return user_game_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = instanceMainVC(name: "game_info") as? Game_info
        vc!.game_id = user_game_arr[indexPath.row].game_id ?? 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}


class User_game_VO {
    var game_title: String?
    var game_id: Int?
    var game_score: Double?
    var game_image_url: String?
}


class User_game_cell: UITableViewCell {
    @IBOutlet var score: CosmosView!
    @IBOutlet var title: UILabel!
    @IBOutlet var thumbnail: UIImageView!
}


