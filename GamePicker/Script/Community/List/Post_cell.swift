import Foundation

class Post_VO {
    var post_isMine: Bool? // 내 글
    var post_id: Int? // 포스트 ID
    var game_id: Int? // game ID
    var post_title: String?
    var post_value: String?
    var user_name: String? // 이름
    var post_views: Int? // 조회수
    var post_created_at: String? // 업데이트 언제
    var game_title: String? // 게임 이름
    var post_recommends: Int? // 추천 몇개
    var post_disrecommends: Int? // 추천 몇개
    var post_comments: Int? // 댓글 몇개
}
