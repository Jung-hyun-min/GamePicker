import UIKit

class TutorialContentsVC: UIViewController {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var bgImageView: UIImageView!
  
  var pageIndex: Int!
  var titleText: String!
  var imageFile: String!
  
  override func viewDidLoad() {
    // 전달받은 타이틀 정보를 레이블 객체에 대입하고 크기를 조절함
    self.titleLabel.text = self.titleText
    self.titleLabel.sizeToFit()
    
    // 전달받은 이미지 정보를 이미지 뷰에 대입함
    self.bgImageView.image = UIImage(named: self.imageFile)
  }
}
