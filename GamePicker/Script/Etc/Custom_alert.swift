import UIKit
import SwiftMessages
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
        config.duration = .seconds(seconds: 1)
        config.presentationStyle = .bottom
        
        SwiftMessages.show(config: config, view: view)
    }
    

    static func score_alert(id: Int, title: String, image: UIImage, completionHandler: @escaping (Double) -> Void) {
        let view: Center_score = try! SwiftMessages.viewFromNib()
        
        view.image.image = image
        view.name.text = title
        
        view.scoreAction = {
            if view.star.rating == 0 {
                view.star.shake(0.5)
            } else {
                SwiftMessages.hide()
                completionHandler(view.star.rating)
            }
        }

        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 20)
        config.dimMode = .color(color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8), interactive: true)
        config.interactiveHide = false

        SwiftMessages.show(config: config, view: view)
    }
}
