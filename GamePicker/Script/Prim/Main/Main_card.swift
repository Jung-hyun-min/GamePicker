import UIKit

class Main_card: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet var CardView: UICollectionView!
    let User_data = UserDefaults.standard
    

    lazy var refreshControl : UIRefreshControl = { // 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl){ // 새로고침 실행 함수
        // 여기에 실행할것 입력 새로고침시;
        self.CardView.reloadData()
        refreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigation_icon()
        self.CardView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "tutorial") == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            self.present(vc!, animated: true)
        } else if UserDefaults.standard.bool(forKey: "login") == false {
            guard let login = self.storyboard?.instantiateViewController(withIdentifier: "select") else { return }
            self.present(login, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { // 섹션 개수
           return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // 섹션별 셀 수
        if section == 0 { // 메세지 섹션
            return 1
        } else { // 게임 추천 섹션
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{ // 섹션별 셀 높이
        if indexPath.section == 0 {
            return CGSize(width: view.frame.size.width - 40, height: 170)
        } else {
            return CGSize(width: view.frame.size.width - 40, height: 380)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { // 메세지 카드
            let message_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "message_card", for: indexPath) as! Message_cell
            
            message_cell.message_title.text   = "정현민님, 우울하신가요?"
            message_cell.message_text.text    = "신규 출시 게임으로 잠시 달래봐요."
            
            // 카드뷰
            message_cell.layer.cornerRadius = 4.0
            message_cell.layer.shadowColor = UIColor.black.cgColor
            message_cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            message_cell.layer.shadowRadius = 12.0
            message_cell.layer.shadowOpacity = 0.7
            
            return message_cell
            
        } else { // 게임 카드
            let game_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "game_card", for: indexPath) as! Main_cell
            
            game_cell.game_name.text = "abc"
            
            game_cell.layer.cornerRadius = 4.0
            game_cell.layer.shadowColor = UIColor.black.cgColor
            game_cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            game_cell.layer.shadowRadius = 12.0
            game_cell.layer.shadowOpacity = 0.7
            
            return game_cell
        }
    }
    
}
