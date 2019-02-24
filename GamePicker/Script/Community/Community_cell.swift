import UIKit
import SwiftyJSON
import Alamofire


class Community_cell: UITableViewCell {
    var parent: UIViewController!
    var post_arr = [Post_VO]()
    var category: String?
    
    @IBOutlet var more: UIButton!
    @IBOutlet var community_title: UILabel!
    @IBOutlet var post_table: UITableView!
    
    func reload() {
        let range = NSMakeRange(0, self.post_table.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.post_table.reloadSections(sections as IndexSet, with: .fade)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        post_table.delegate = self
        post_table.dataSource = self
    }
}


extension Community_cell: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post_cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as! Post_cell
        let row = self.post_arr[indexPath.row]
        
        post_cell.post_title.text = row.post_title
        
        post_cell.post_recommends.text = String(row.post_recommends!)
        post_cell.post_comments.text = "["+String(row.post_comments!)+"]"
        post_cell.post_views.text = String(row.post_views!)
        
        if row.post_isMine! {
            post_cell.user_name.font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        post_cell.post_created_at.text = dateFormatter.date(from: row.post_created_at!)?.relativeTime
    
        if category == "games" {
            post_cell.game_title.isHidden = false
            post_cell.game_title.text = row.game_title
        }
        
        if category == "anonymous" {
            post_cell.user_name.text = "익명"
        } else {
            post_cell.user_name.text = row.user_name
        }
        
        return post_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let child = parent.instanceMainVC(name: "post_read") as? Post_read
        child!.post_id = post_arr[indexPath.row].post_id!
        child?.category = category
        child?.game_title = post_arr[indexPath.row].game_title ?? category!
        parent.navigationController?.pushViewController(child!, animated: true)
    }
}
