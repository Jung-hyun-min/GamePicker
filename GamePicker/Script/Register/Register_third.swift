import UIKit

class Register_third: UIViewController {
    @IBOutlet var next_but: UIButton!
    
    var mail : String = ""
    var password : String = ""
    var birth : String = ""
    
    @IBOutlet var gender: UISegmentedControl!

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

    @IBAction func value_changed(_ sender: Any) {
        next_but.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        next_but.isEnabled = true
    }
    
    @IBAction func next(_ sender: Any) {
        performSegue(withIdentifier: "fourth", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Register_fourth
        vc.mail = mail
        vc.password = password
        vc.birth = birth
        if gender.selectedSegmentIndex == 0 {
            vc.gender = "M"
        } else {
            vc.gender = "F"
        }
    }
}
