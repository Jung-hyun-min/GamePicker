import UIKit

class Register_third: UIViewController {

    var mail : String = ""
    var password : String = ""
    var birth : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        performSegue(withIdentifier: "fourth", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Register_fourth
        vc.mail = mail
        vc.password = password
        //vc.birth = birth.date
    }
}
