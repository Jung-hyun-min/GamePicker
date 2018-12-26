import UIKit

class Message_cell: UICollectionViewCell {
    @IBOutlet var message_info: UILabel!
    
    @IBOutlet var message_title: UILabel!
    @IBOutlet var message_text: UILabel!
    @IBOutlet var message_confirm: UIButton!
    @IBOutlet var message_cancel: UIButton!
    
    @IBOutlet var message_discard: UIButton!
}
