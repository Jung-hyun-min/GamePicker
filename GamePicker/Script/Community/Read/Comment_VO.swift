import Foundation

class Comment_VO {
    
    var comment_id: Int? 
    var comment_value: String?
    var recommends: Int?
    var disrecommends: Int?
    var created_at: String?
    var user_name: String?
    var user_id: Int?
    
    var re_comment_arr = [Comment_VO]()
    
}
