import UIKit

class Main_cell: UITableViewCell {
    @IBOutlet var card_view: UIView!
    
    @IBOutlet var rate_view: UIView!
    
    @IBOutlet var game_image: UIImageView!
    @IBOutlet var game_name: UILabel!
    
    @IBOutlet var more_but: UIButton!
    
    @IBOutlet var game_platform: UILabel!
    
    @IBOutlet var game_rating1: UILabel!
    @IBOutlet var rating_star: UIImageView!
    @IBOutlet var game_rating2: UILabel!
    @IBOutlet var game_rating_num: UILabel!
    
    @IBOutlet var favorite: UIStackView!
    @IBOutlet var score: UIStackView!
    @IBOutlet var community: UIStackView!
    
    @IBOutlet var heart: UIImageView!
    
}
