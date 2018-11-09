import Firebase
import UIKit

class Com_card: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet var CardView: UICollectionView!
    
    lazy var refreshControl : UIRefreshControl = { // 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.actualizerData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func actualizerData(_ refreshControl : UIRefreshControl){  // 새로고침 실행 함수
        // 여기에 실행할것 입력 새로고침시;
        self.CardView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.CardView.addSubview(self.refreshControl)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { // 섹션 개수
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if indexPath.section == 0 {
            return CGSize(width: view.frame.size.width - 30, height: 150)
        } else {
            return CGSize(width: view.frame.size.width - 30, height: 185)
        }
    }
    
    let sort_array = ["전체 게시판","자유 게시판","짤방 게시판","질문 게시판"]
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { // 메세지 카드
            let message_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "message_card", for: indexPath) as! Message_cell
            
            message_cell.message_title.text = "질문을 할까요?"
            message_cell.message_text.text = "안녕하십니까?"
            message_cell.message_confirm.setTitle("설정하러 가기!", for: .normal)
            
            // 여기는 카드뷰로 만드는 영역
            message_cell.contentView.layer.cornerRadius = 4.0
            message_cell.contentView.layer.borderWidth = 1.0
            message_cell.contentView.layer.borderColor = UIColor.clear.cgColor
            message_cell.contentView.layer.masksToBounds = false
            message_cell.layer.shadowColor = UIColor.gray.cgColor
            message_cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            message_cell.layer.shadowRadius = 3.0
            message_cell.layer.shadowOpacity = 1.0
            message_cell.layer.masksToBounds = false
            message_cell.layer.shadowPath = UIBezierPath(roundedRect: message_cell.bounds, cornerRadius: message_cell.contentView.layer.cornerRadius).cgPath
            
            return message_cell
        } else { // 게임 카드
            let com_cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com_card", for: indexPath) as! Com_cell
            
            com_cell.com_sort.text = sort_array[indexPath.row]
            
            com_cell.first_date.text = "2004-10-20"
            com_cell.first_prev.text = "안녕하세요 저는 삼학년팔반이십사번 정현민 입니다. 잘부탁 드립"
            com_cell.first_comment.text = "[22]"
            com_cell.first_image.isHidden = true
            
            com_cell.second_date.text = "2018-9-12"
            com_cell.second_prev.text = "게시판 일단 체크"
            com_cell.second_comment.text = "[4]"
            com_cell.second_image.isHidden = false
            
            com_cell.third_date.text = "2002-6-22"
            com_cell.third_prev.text = "길이 어느정도가 적당할까"
            com_cell.third_comment.text = "[1]"
            com_cell.third_image.isHidden = true
            
            com_cell.fourth_date.text = "2129-12-31"
            com_cell.fourth_prev.text = "ios 게시판"
            com_cell.fourth_comment.text = ""
            com_cell.fourth_image.isHidden = false
            
            com_cell.com_sort_but.tag = indexPath.row
            com_cell.com_sort_but.addTarget(self, action: #selector(self.more_but), for: .touchUpInside)
            // 여기는 카드뷰로 만드는 영역
            com_cell.contentView.layer.cornerRadius = 4.0
            com_cell.contentView.layer.borderWidth = 1.0
            com_cell.contentView.layer.borderColor = UIColor.clear.cgColor
            com_cell.contentView.layer.masksToBounds = false
            com_cell.layer.shadowColor = UIColor.gray.cgColor
            com_cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            com_cell.layer.shadowRadius = 3.0
            com_cell.layer.shadowOpacity = 1.0
            com_cell.layer.masksToBounds = false
            com_cell.layer.shadowPath = UIBezierPath(roundedRect: com_cell.bounds, cornerRadius: com_cell.contentView.layer.cornerRadius).cgPath
            
            return com_cell
        }
    }

    @objc func more_but(sender: UIButton) {
        self.performSegue(withIdentifier: "com_list", sender: sender.tag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let param = segue.destination as! Com_table
        param.flag = sender as! Int
    }

}
