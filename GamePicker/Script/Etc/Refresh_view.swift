import UIKit

class Refresh_view: UIView {
    @IBOutlet var state_message: UILabel!
    
    func start() {
        state_message.text = "새로운 게임을 가져오는중"
    }
    
    func stop() {
        state_message.text = "새로운 게임을 가져왔다."
    }
}
