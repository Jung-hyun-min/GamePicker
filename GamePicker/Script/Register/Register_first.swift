import UIKit

class Register_first: UIViewController,UITextFieldDelegate {
    @IBOutlet var first: NSLayoutConstraint!
    @IBOutlet var second: NSLayoutConstraint!
    @IBOutlet var third: NSLayoutConstraint!
    @IBOutlet var fourth: NSLayoutConstraint!
    @IBOutlet var fifth: NSLayoutConstraint!
    
    @IBOutlet var text1: UITextView!
    @IBOutlet var text2: UITextView!
    
    @IBOutlet var mail_field: UITextField!
    @IBOutlet var password_field: UITextField!
    @IBOutlet var password_chk_field: UITextField!
    
    @IBOutlet var mail_under: UIView!
    @IBOutlet var password_under: UIView!
    @IBOutlet var password_chk_under: UIView!
    
    @IBOutlet var mail_warn_stack: UIStackView!
    @IBOutlet var password_warn_stack: UIStackView!
    @IBOutlet var password_chk_warn_stack: UIStackView!
    
    @IBOutlet var mail_warn_text: UILabel!
    @IBOutlet var password_warn_text: UILabel!
    @IBOutlet var password_chk_warn_text: UILabel!
    
    @IBOutlet var mail_del_but: UIButton!
    @IBOutlet var password_del_but: UIButton!
    @IBOutlet var password_chk_del_but: UIButton!
    
    @IBOutlet var password_chk_chk: UIImageView!
    
    @IBOutlet var first_box: UIButton!
    @IBOutlet var second_box: UIButton!
    
    @IBOutlet var first_more: UIButton!
    @IBOutlet var second_more: UIButton!
    
    var fst_box_clk : Int = 0
    var snd_box_clk : Int = 0
    
    var fst_more_clk : Int = 0
    var snd_more_clk : Int = 0
    
    @IBOutlet var next_but: UIButton!
    
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(endEditing))
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        var nextButton = UIBarButtonItem(image: UIImage(named: "ic_more_close"), style: .plain, target: self, action: #selector(up))
        var previousButton = UIBarButtonItem(image: UIImage(named: "ic_more"), style: .plain, target: self, action: #selector(down))
        
        toolbar.setItems([fixedSpaceButton, nextButton, fixedSpaceButton, previousButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        first.constant = 18
        second.constant = 18
        third.constant = 23
        fourth.constant = 15
        fifth.constant = 25
        
        text1.isHidden = true
        text2.isHidden = true
        
        text1.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        text1.layer.borderWidth = 1.0
        text1.layer.cornerRadius = 5.0
        text2.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        text2.layer.borderWidth = 1.0
        text2.layer.cornerRadius = 5.0
        
        text1.textContainerInset = .init(top: 14, left: 14, bottom: 14, right: 14)
        text2.textContainerInset = .init(top: 14, left: 14, bottom: 14, right: 14)
        
        next_but.layer.cornerRadius = 6
        
        mail_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        password_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        password_chk_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        next_but.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        
        mail_warn_stack.isHidden = true
        password_warn_stack.isHidden = true
        password_chk_warn_stack.isHidden = true
        
        mail_del_but.isHidden = true
        password_del_but.isHidden = true
        password_chk_del_but.isHidden = true
        
        password_chk_chk.isHidden = true
        
        next_but.isEnabled = false
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @IBAction func back(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "회원가입을 취소하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        let ok = UIAlertAction(title: "가입 취소", style: .destructive) {
            (result:UIAlertAction) -> Void in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    @objc func endEditing() {
        mail_field.resignFirstResponder()
        password_field.resignFirstResponder()
        password_chk_field.resignFirstResponder()
    }
    
    @IBAction func mail_del(_ sender: Any) {
        mail_field.becomeFirstResponder()
        mail_field.text = ""
        mail_del_but.isHidden = true
    }
    @IBAction func password_del(_ sender: Any) {
        password_field.becomeFirstResponder()
        password_field.text = ""
        password_del_but.isHidden = true
    }
    @IBAction func password_chk_Del(_ sender: Any) {
        password_chk_field.becomeFirstResponder()
        password_chk_field.text = ""
        password_chk_chk.isHidden = true
        password_chk_del_but.isHidden = true
    }
    
    @IBAction func first_box(_ sender: Any) {
        if fst_box_clk == 0 {
            fst_box_clk = 1
            first_box.setImage(UIImage(named: "ic_check_on.png"), for: .normal)
            next_chk()
        } else {
            fst_box_clk = 0
            first_box.setImage(UIImage(named: "ic_check_off.png"), for: .normal)
            next_chk()
        }
    }
    
    @IBAction func second_box(_ sender: Any) {
        if snd_box_clk == 0 {
            snd_box_clk = 1
            second_box.setImage(UIImage(named: "ic_check_on.png"), for: .normal)
            next_chk()
        } else {
            snd_box_clk = 0
            second_box.setImage(UIImage(named: "ic_check_off.png"), for: .normal)
            next_chk()
        }
    }
    
    func next_chk() {
        if snd_box_clk == 1 && fst_box_clk == 1 {
            if mail_field.text != "" && password_field.text != "" && password_chk_field.text != "" {
                next_but.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
                next_but.isEnabled = true
                return
            }
        }
        next_but.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
        next_but.isEnabled = false
    }
    
    @IBAction func first_more(_ sender: Any) {
        if fst_more_clk == 0 {
            fst_more_clk = 1
            text1.isHidden = false
            fourth.constant = 160
            first_more.setImage(UIImage(named: "ic_more.png"), for: .normal)
            next_chk()
        } else {
            fst_more_clk = 0
            text1.isHidden = true
            fourth.constant = 15
            first_more.setImage(UIImage(named: "ic_more_close.png"), for: .normal)
            next_chk()
        }
    }
    
    @IBAction func second_more(_ sender: Any) {
        if snd_more_clk == 0 {
            snd_more_clk = 1
            text2.isHidden = false
            fifth.constant = 170
            second_more.setImage(UIImage(named: "ic_more.png"), for: .normal)
            next_chk()
        } else {
            snd_more_clk = 0
            text2.isHidden = true
            fifth.constant = 25
            second_more.setImage(UIImage(named: "ic_more_close.png"), for: .normal)
            next_chk()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if mail_field.isFirstResponder {
            password_field.becomeFirstResponder()
        } else if password_field.isFirstResponder {
            password_chk_field.becomeFirstResponder()
        } else {
            endEditing()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        next_chk()
        if textField == mail_field {
            mail_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            if textField.text != "" {
                mail_del_but.isHidden = false
            }
        } else if textField == password_field {
            password_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            if textField.text != "" {
                password_del_but.isHidden = false
            }
        } else if textField == password_chk_field {
            password_chk_under.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            if textField.text != "" {
                password_chk_del_but.isHidden = false
            }
        }
        if textField == password_chk_field || textField == password_field {
            if password_chk_field.text != "" && password_field.text != "" {
                if password_chk_field.text == password_field.text {
                    password_chk_chk.isHidden = false
                    password_chk_warn_stack.isHidden = true
                    return
                }
            }
            password_chk_chk.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mail_field {
            if range.location <= 1 {
                mail_del_but.isHidden = true
                mail_warn_stack.isHidden = true
                first.constant = 18
            } else {
                mail_del_but.isHidden = false
            }
        } else if textField == password_field {
            if range.location <= 1 {
                password_del_but.isHidden = true
                password_warn_stack.isHidden = true
                second.constant = 18
            } else {
                password_del_but.isHidden = false
            }
        } else if textField == password_chk_field {
            if range.location <= 1 {
                password_chk_del_but.isHidden = true
                password_chk_warn_stack.isHidden = true
                password_chk_chk.isHidden = true
                third.constant = 23
            } else {
                password_chk_del_but.isHidden = false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = inputToolbar
        if textField == mail_field {
            mail_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
        else if textField == password_field {
            password_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
        else if textField == password_chk_field {
            password_chk_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
    }
    
    @objc func up() {
        if mail_field.isFirstResponder {
            endEditing()
        } else if password_field.isFirstResponder {
            mail_field.becomeFirstResponder()
        } else {
            password_field.becomeFirstResponder()
        }
    }
    
    @objc func down() {
        if mail_field.isFirstResponder {
            password_field.becomeFirstResponder()
        } else if password_field.isFirstResponder {
            password_chk_field.becomeFirstResponder()
        } else {
            endEditing()
        }
    }
    
    @IBAction func next(_ sender: Any) {
        // 오류 핸들링 추가
        if password_chk_field.text != password_field.text {
            password_chk_field.becomeFirstResponder()
            password_chk_warn_stack.isHidden = false
            password_chk_warn_text.text = "비밀번호 확인이 틀렸습니다."
            third.constant = 35
            return
        }
        performSegue(withIdentifier: "second", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Register_second
        vc.mail = mail_field.text ?? ""
        vc.password = password_field.text ?? ""
    }
}
