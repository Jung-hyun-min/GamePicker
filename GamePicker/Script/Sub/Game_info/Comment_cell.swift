import UIKit

class Comment_cell: UITableViewCell {
    
    @IBOutlet var profile: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var date: UILabel!

    @IBOutlet var score: UILabel!
    
    @IBOutlet var like: UIButton!
    @IBOutlet var dislike: UIButton!
    @IBOutlet var recomment: UIButton!
}
