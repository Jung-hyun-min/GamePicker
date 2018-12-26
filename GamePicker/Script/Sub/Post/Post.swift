import UIKit
import Alamofire
import SwiftyJSON

class Post: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var table: UITableView!
    
    let api = Api_url()
    
    var game_id : Int = 0
    var game_title : String = ""
    
    lazy var post_arr : [Post_VO] = {
        var datalist = [Post_VO]()
        return datalist
    }()
    
    // 스와이프 리프레시
    lazy var refreshControl : UIRefreshControl = { // 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl) {
        refresh()
        refreshControl.endRefreshing()
    }
    
    // 새로고침 실행
    @objc func refresh() {
        post_arr.removeAll()
        self.get_posts()
        self.table.reloadData()
    }
    
    @objc func write() {
        performSegue(withIdentifier: "write", sender: game_id)
    }
    
    @objc func search() {
        showalert(message: "준비중인 기능입니다.", can: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "read" {
            let param = segue.destination as! Post_read
            param.post_id = sender as! Int
        }
        else {
            let param = segue.destination as! Post_write
            param.game_id = game_id
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationbar()
        if game_id == 0 {
            self.navigationItem.title = "자유 게시판"
        }
        
        navigationItem.title = game_title
        get_posts()
        self.table.addSubview(self.refreshControl)
    }
    
    func navigationbar() {
        let refresh = UIImage(named: "refresh")!
        let write = UIImage(named: "write")!
        let search = UIImage(named: "search")!
        
        let refresh_but: UIButton = UIButton.init(type: .custom)
        refresh_but.setImage(refresh, for: UIControl.State.normal)
        refresh_but.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.touchUpInside)
        refresh_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let refresh_item = UIBarButtonItem(customView: refresh_but)
        
        let write_but: UIButton = UIButton.init(type: .custom)
        write_but.setImage(write, for: UIControl.State.normal)
        write_but.addTarget(self, action: #selector(self.write), for: UIControl.Event.touchUpInside)
        write_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let write_item = UIBarButtonItem(customView: write_but)
        
        let search_but: UIButton = UIButton.init(type: .custom)
        search_but.setImage(search, for: UIControl.State.normal)
        search_but.addTarget(self, action: #selector(self.search), for: UIControl.Event.touchUpInside)
        search_but.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let search_item = UIBarButtonItem(customView: search_but)
        search_item.tintColor = UIColor.white
        
        self.navigationItem.setRightBarButtonItems([search_item, write_item, refresh_item], animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell") as! Post_cell
        let row = self.post_arr[indexPath.row]
    
        cell.title?.text = row.title
        cell.content?.text = row.content
        cell.update?.text = row.update_date
        cell.name?.text = row.name
        cell.recommend?.text = "\(row.recommends ?? 0)"
        cell.comment?.text = "\(row.comment_count ?? 0)"
        cell.view?.text = "\(row.views ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.post_arr[indexPath.row]
        let post_id : Int = row.id ?? 0
        self.performSegue(withIdentifier: "read", sender: post_id)
    }
    
    func get_posts() {
        print("gameID : \(game_id)")
        let url = api.pre + "posts?gameID=\(game_id)"
        
        Alamofire.request(url).responseJSON { (response) in
            if response.result.isSuccess {
                // 성공 했을 때
                if (response.result.value) != nil {
                    let json = JSON(response.result.value!)
                    let count = json["data"]["count"].intValue
                    print("\(count) posts in DB")
                    if count == 0 {
                        self.table.isHidden = true
                        return
                    }
                    for (_,subJson):(String, JSON) in json["data"]["posts"] {
                        let pst = Post_VO()
                        pst.id            = subJson["id"].intValue
                        pst.game_id       = subJson["game_id"].intValue
                        pst.title         = subJson["title"].stringValue
                        pst.name          = subJson["name"].stringValue
                        pst.content       = subJson["content"].stringValue
                        pst.views         = subJson["views"].intValue
                        pst.update_date   = subJson["update_date"].stringValue
                        pst.category      = subJson["category"].stringValue
                        pst.recommends    = subJson["recommends"].intValue
                        pst.comment_count = subJson["comment_count"].intValue
                        self.post_arr.append(pst)
                    }
                    self.table.reloadData()
                }
            } else {
                self.showalert(message: "게시글 데이터 API 오류\n" + response.result.debugDescription, can: 0)
            }
        }
    }

}
