import UIKit
import SwiftMessages

class Bottom_red: MessageView {
    @IBOutlet var title: UILabel!
    
    var cancelAction: (() -> Void)?
    
    @IBAction func cancel() {
        cancelAction?()
    }
}

class Center_logout: MessageView {
    var logoutAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    @IBAction func logout(_ sender: Any) {
        logoutAction?()
    }
    
    @IBAction func cancel(_ sender: Any) {
        cancelAction?()
    }
}

class custom_alert {
    
    static func red_alert(text: String) {
        let view: Bottom_red = try! SwiftMessages.viewFromNib()
        view.cancelAction = { SwiftMessages.hide() }
        view.title.text = text
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        SwiftMessages.show(config: config, view: view)
    }
    
}
