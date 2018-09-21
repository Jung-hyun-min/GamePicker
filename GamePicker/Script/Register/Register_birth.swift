import UIKit

class Register_birth: UIViewController {
    @IBOutlet var hello: UILabel!
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var birth_o: UIDatePicker!
    
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = User?.name {
            hello.text = name + " 님 안녕하세요"
        }
        next_but_o.layer.cornerRadius = 5
    }
    
    @IBAction func undo(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "생일 입력 취소", style: .default) {
            (result:UIAlertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
        }
        let ok2 = UIAlertAction(title: "회원가입 취소", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addAction(ok2)
        self.present(alert,animated: true)
    }
    
    @IBAction func next_but_a(_ sender: Any) {
        print(birth_o.date)
        let dateformatter1 = DateFormatter()
        let dateformatter2 = DateFormatter()
        dateformatter1.dateFormat = "yyyy년 MM월 dd일"
        dateformatter2.dateFormat = "yyyyMMdd"
        let alert_title : String = dateformatter1.string(from: birth_o.date)
        let birth : String = dateformatter2.string(from: birth_o.date)
        User?.birth = birth
        let alert = UIAlertController(title: alert_title, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "아니에요", style: .cancel)
        let ok = UIAlertAction(title: "맞아요", style: .default) {
            (result:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "sex", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }

}
