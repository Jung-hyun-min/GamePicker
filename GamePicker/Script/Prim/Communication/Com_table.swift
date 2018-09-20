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
    var mTimer : Timer?
    var time_second : Int = 0
    
    var array = ["게시판","테스트","셀"]
    
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
    
    @IBAction func refresh_bar(_ sender: Any) {
        refresh_but.isEnabled = false
        if let timer = mTimer {
            if !timer.isValid {
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        }else{
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        refresh()
    }
    @objc func timerCallback(){
        time_second += 1
        if time_second == 3 {
            if let timer = mTimer {
                if(timer.isValid){
                    refresh_but.isEnabled = true
                    timer.invalidate()
                }
            }
            time_second = 0
        }
    }
    
    func refresh() {
        let title = "새로고침 테스트"
        array.append(title)
        self.table.reloadData()
    } // 새로 고침의 실질적 코드
    
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


}
