import UIKit

class Comment_cell: UITableViewCell {
    
    @IBOutlet var profile_image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var created_at: UILabel!

    @IBOutlet var score: UILabel!
    
    @IBOutlet var like_but: UIButton!
    @IBOutlet var dislike_but: UIButton!
    @IBOutlet var recomment_but: UIButton!
    
}

class Re_comment_cell: UITableViewCell {
    
    @IBOutlet var profile_image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var created_at: UILabel!
    
    @IBOutlet var score: UILabel!
    
    @IBOutlet var like_but: UIButton!
    @IBOutlet var dislike_but: UIButton!
    
}
