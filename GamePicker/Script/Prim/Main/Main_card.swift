import UIKit
import Firebase

class Main_card: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    // 카드뷰
    @IBOutlet var CardView: UICollectionView!
    
    // 유저데이터
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
    
    let game_title_array = ["first","second","third","fourth"]
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { // 섹션 개수
           return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { // 섹션별 셀 수
        if section == 0 { // 메세지 섹션
            return 1
        }
        if section == 1 { // 게임 추천 섹션
            return 4
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{ // 섹션별 셀 높이
        if indexPath.section == 0 {
            return CGSize(width: view.frame.size.width - 30, height: 150)
        } else {
            return CGSize(width: view.frame.size.width - 30, height: 380)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { // 메세지 카드
            let message_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "message_card", for: indexPath) as! Message_cell
            
            message_cell.message_title.text   = "질문을 할까요?"
            message_cell.message_text.text    = "안녕하십니까?"
            message_cell.message_confirm.setTitle("설정하러 가기!", for: .normal)
            
            //사실 여기는 카드뷰로 만드는 영역임
            message_cell.contentView.layer.cornerRadius  = 4.0
            message_cell.contentView.layer.borderWidth   = 1.0
            message_cell.contentView.layer.borderColor   = UIColor.clear.cgColor
            message_cell.contentView.layer.masksToBounds = false
            message_cell.layer.shadowColor   = UIColor.gray.cgColor
            message_cell.layer.shadowOffset  = CGSize(width: 0, height: 1)
            message_cell.layer.shadowRadius  = 6.0
            message_cell.layer.shadowOpacity = 1.0
            message_cell.layer.masksToBounds = false
            message_cell.layer.shadowPath    = UIBezierPath(roundedRect: message_cell.bounds, cornerRadius: message_cell.contentView.layer.cornerRadius).cgPath
            
            return message_cell
            
        } else { // 게임 카드
            let game_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "game_card", for: indexPath) as! Main_cell
            
            game_cell.game_name.text = game_title_array[indexPath.row]
            
            return game_cell
        }
    }
    
}
