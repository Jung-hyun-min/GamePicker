import UIKit
import SwiftMessages
import Kingfisher
import Cosmos
import Alamofire
import SwiftyJSON

class Bottom_red: MessageView {
    @IBOutlet var title: UILabel!
    @IBAction func cancel() {
        SwiftMessages.hide()
    }
}

class Center_logout: MessageView {
    var logoutAction: (() -> Void)?
    
    @IBAction func logout(_ sender: Any) {
        logoutAction?()
    }
    
    @IBAction func cancel(_ sender: Any) {
        SwiftMessages.hide()
    }
}

class Center_score: MessageView {
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet weak var star: CosmosView!
    
    
    var scoreAction: (() -> Void)?
    
    @IBAction func logout(_ sender: Any) {
        scoreAction?()
    }
    @IBAction func cancel(_ sender: Any) {
        SwiftMessages.hide()
    }
}

class custom_alert {
    static func red_alert(text: String) {
        let view: Bottom_red = try! SwiftMessages.viewFromNib()
        view.title.text = text
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        SwiftMessages.show(config: config, view: view)
    }
    
    private static var game_rating : Double = 2.5
    
    static func score_alert(id: Int, title: String, image: UIImage) {
        let view: Center_score = try! SwiftMessages.viewFromNib()
        
        view.name.text = title
        view.image.kf.indicatorType = .activity
        /*
        view.image.kf.setImage(
            with: URL(string: image),
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 90, height: 90))),
                .scaleFactor(UIScreen.main.scale),
            ])
        */
        view.image.image = image
        view.scoreAction = {
            SwiftMessages.hide()
            post_score(id: id)
        }
        
        view.star.rating = game_rating
        view.star.didTouchCosmos = didTouchCosmos

        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 20)
        config.dimMode = .color(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8), interactive: true)
        config.interactiveHide = false

        SwiftMessages.show(config: config, view: view)
    }

    static func didTouchCosmos(_ rating: Double) {
        game_rating = rating
    }
    
    private static func post_score(id: Int) {
        let parameter: [String: Any] = [
            "score" : game_rating
        ]
        
        let header: [String : String] = [
            "x-access-token" : UserDefaults.standard.string(forKey: data.user.token) ?? ""
        ]
        
        Alamofire.request(Api.url + "games/\(id)/reviews",
                            method: .post, parameters: parameter,
                            headers: header).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 204 {
                    self.red_alert(text: "평가 완료")
                } else if response.response?.statusCode ?? 0 < 500 {
                    self.red_alert(text: json["message"].stringValue)
                } else {
                    self.red_alert(text: "서버 오류")
                }
            } else {
                self.red_alert(text: "서버 응답 없음")
            }
        }
    }
    
    
}
