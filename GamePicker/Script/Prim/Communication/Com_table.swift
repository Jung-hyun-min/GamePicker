//
//  Com_table.swift
//  GamePicker
//
//  Created by 정현민 on 2018. 9. 19..
//  Copyright © 2018년 정현민. All rights reserved.
//

import UIKit

class Com_table: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var refresh_but: UIBarButtonItem!
    
    var flag : Int = 0
    
    var array = ["게시판","테스트","셀"]
    
    // 스와이프 리프레시
    lazy var refreshControl : UIRefreshControl = { // 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl){
        refresh()
        refreshControl.endRefreshing()
    }
    
    // 네비게이션 바 새로고침
    @IBAction func refresh_bar(_ sender: Any) {
        refresh()
    }
    
    // 새로고침 실행
    func refresh() {
        let title = "새로고침 테스트"
        array.append(title)
        self.table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.addSubview(self.refreshControl)
        
        if flag == 0 {self.navigationItem.title = "전체 게시판"}
        else if flag == 1 {self.navigationItem.title = "자유 게시판"}
        else if flag == 2 {self.navigationItem.title = "짤방 게시판"}
        else if flag == 3 {self.navigationItem.title = "질문 게시판"}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell") as! Com_table_cell
        cell.content_prev.text = array[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }


}
