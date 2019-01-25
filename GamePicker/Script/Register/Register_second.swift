import UIKit

class Register_second: UIViewController {
    @IBOutlet var birth: UIDatePicker!
    
    var mail : String = ""
    var password : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "생일입력 취소", style: .default) {
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
    
    @IBAction func next(_ sender: Any) {
        print(birth.date)
        let dateformatter1 = DateFormatter()
        dateformatter1.dateFormat = "yyyy년 MM월 dd일"
        let alert_title : String = dateformatter1.string(from: birth.date)

        let alert = UIAlertController(title: alert_title, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "아니요", style: .cancel)
        let ok = UIAlertAction(title: "맞아요", style: .default) {
            (result:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "third", sender: self)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Register_third
        vc.mail = mail
        vc.password = password
        
        let dateformatter2 = DateFormatter()
        dateformatter2.dateFormat = "yyyy-MM-dd"
        let date : String = dateformatter2.string(from: birth.date)
        vc.birth = date
    }
}


