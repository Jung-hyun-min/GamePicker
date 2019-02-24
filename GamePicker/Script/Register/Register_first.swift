import UIKit
import Alamofire
import SwiftyJSON

class Register_first: UIViewController {
    @IBOutlet weak var first: NSLayoutConstraint!
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
    
    @IBOutlet var password_chk_chk: UIImageView!
    
    @IBOutlet var first_box: UIButton!
    @IBOutlet var second_box: UIButton!
    
    @IBOutlet var first_more: UIButton!
    @IBOutlet var second_more: UIButton!
    
    @IBOutlet var next_but: UIButton!
    
    var fst_box_clk: Int = 0
    var snd_box_clk: Int = 0
    
    var fst_more_clk: Int = 0
    var snd_more_clk: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addToolBar(textField: mail_field, title: "다음")
        addToolBar(textField: password_field, title: "다음")
        addToolBar(textField: password_chk_field, title: "다음")

        text1.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        text2.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
        
        text1.textContainerInset = .init(top: 16, left: 14, bottom: 16, right: 14)
        text2.textContainerInset = .init(top: 16, left: 14, bottom: 16, right: 14)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        hideKeyboard_tap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! Register_second
        vc.mail     = mail_field.text ?? ""
        vc.password = password_field.text ?? ""
    }
    
    override func barPressed() {
        if mail_field.isFirstResponder {
            mail_chk { result in
                if result {
                    self.password_field.becomeFirstResponder()
                } else {
                    self.mail_warn_stack.shake(0.5)
                    self.mail_under.shake(0.5)
                }
            }
        } else if password_field.isFirstResponder {
            if password_chk() {
                password_chk_field.becomeFirstResponder()
            } else {
                password_warn_stack.shake(0.5)
                password_under.shake(0.5)
            }
        } else {
            if password_equal_chk() {
                password_chk_field.resignFirstResponder()
            } else {
                password_chk_warn_stack.shake(0.5)
                password_under.shake(0.5)
            }
        }
    }
    
    
    // 뒤로가기
    @IBAction func back(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "회원가입을 취소하시겠습니까?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "닫기", style: .cancel)
        let ok = UIAlertAction(title: "가입 취소", style: .destructive) { UIAlertAction in
            self.presentingViewController?.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
    
    /* 약관 동의 박스 */
    @IBAction func first_box(_ sender: Any) {
        if fst_box_clk == 0 {
            fst_box_clk = 1
            first_box.setImage(UIImage(named: "ic_check_on"), for: .normal)
            next_chk()
        } else {
            fst_box_clk = 0
            first_box.setImage(UIImage(named: "ic_check_off"), for: .normal)
            next_chk()
        }
    }
    
    @IBAction func second_box(_ sender: Any) {
        if snd_box_clk == 0 {
            snd_box_clk = 1
            second_box.setImage(UIImage(named: "ic_check_on"), for: .normal)
            next_chk()
        } else {
            snd_box_clk = 0
            second_box.setImage(UIImage(named: "ic_check_off"), for: .normal)
            next_chk()
        }
    }
    
    
    /* 약관동의 추가보기 액션 함수 */
    @IBAction func first_more(_ sender: Any) {
        if fst_more_clk == 0 {
            fst_more_clk = 1
            text1.isHidden = false
            fourth.constant = 180
            first_more.setImage(UIImage(named: "ic_more"), for: .normal)
            next_chk()
        } else {
            fst_more_clk = 0
            text1.isHidden = true
            fourth.constant = 30
            first_more.setImage(UIImage(named: "ic_more_close"), for: .normal)
            next_chk()
        }
    }
    
    @IBAction func second_more(_ sender: Any) {
        if snd_more_clk == 0 {
            snd_more_clk = 1
            text2.isHidden = false
            fifth.constant = 210
            second_more.setImage(UIImage(named: "ic_more"), for: .normal)
            next_chk()
        } else {
            snd_more_clk = 0
            text2.isHidden = true
            fifth.constant = 40
            second_more.setImage(UIImage(named: "ic_more_close"), for: .normal)
            next_chk()
        }
    }
    
    
    // 다음 버튼 액션 함수
    @IBAction func next(_ sender: Any) {
        guard password_chk() && password_equal_chk() else {
            self.next_but.shake(0.5)
            self.next_but.setTitle("비밀번호 확인", for: .normal)
            return
        }
        
        mail_chk() { result in
            if result {
                self.performSegue(withIdentifier: "second", sender: self)
            } else {
                self.next_but.shake(0.5)
                self.next_but.setTitle("이메일 확인", for: .normal)
            }
        }
        
    }
    
    
    /* util funcitons */
    // 이메일 체크
    func mail_chk(completionHandler: @escaping (Bool) -> Void) {
        if mail_field.text!.isEmpty {
            // 메일 필드가 비어있을 경우
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일을 입력하세요."
            first.constant = 33
            completionHandler(false)
            return
        } else if !isValidEmailAddress(email: mail_field.text!) {
            // 메일 형식 오류
            mail_warn_stack.isHidden = false
            mail_warn_text.text = "이메일 형식을 맞춰주세요."
            first.constant = 33
            completionHandler(false)
            return
        }
        
        print("mail 중복 체크..")
        // 메일 중복 체크
        get_email_isOverlap() { result in
            if result {
                // 이메일 중복
                self.mail_warn_stack.isHidden = false
                self.mail_warn_text.text = "이미 가입한 계정입니다."
                self.first.constant = 33
                completionHandler(false)
                return
            } else {
                // 모든 테스트 통과
                self.mail_warn_stack.isHidden = true
                self.first.constant = 18
                completionHandler(true)
                return
            }
        }
    }
    
    // 비밀번호 체크
    func password_chk() -> Bool {
        if password_field.text!.isEmpty {
            // 비밀번호 필드가 비어있을 경우
            password_warn_stack.isHidden = false
            password_warn_text.text = "비밀번호를 입력하세요."
            second.constant = 33
            return false
        } else if (password_field.text?.count)! < 8 || (password_field.text?.count)! > 16 {
            // 비밀번호 범위 초과
            password_warn_stack.isHidden = false
            password_warn_text.text = "비밀번호를 8~16자로 설정해주세요."
            second.constant = 33
            return false
        } else if !isValidPassword(password: password_field.text!) {
            // 비밀번호 필드가 비어있을 경우
            password_warn_stack.isHidden = false
            password_warn_text.text = "비밀번호 형식을 맞춰주세요."
            second.constant = 33
            return false
        } else if !password_chk_field.text!.isEmpty {
            if password_chk_field.text == password_field.text {
                third.constant = 30
                password_chk_chk.isHidden = false
                password_chk_warn_stack.isHidden = true
            }
        }
        // 모든 테스트 통과시
        second.constant = 18
        password_warn_stack.isHidden = true
        return true
        
    }
    
    // 비밀번호 확인 체크
    func password_equal_chk() -> Bool {
        if password_chk_field.text!.isEmpty {
            // 비밀번호 확인 필드가 비어있을 경우
            password_chk_chk.isHidden = true
            password_chk_warn_stack.isHidden = false
            password_chk_warn_text.text = "비밀번호를 한번더 입력하세요."
            third.constant = 45
            return false
        } else if password_chk_field.text != password_field.text {
            // 비밀번호 확인과 비밀번호가 다를 경우
            password_chk_chk.isHidden = true
            password_chk_warn_stack.isHidden = false
            password_chk_warn_text.text = "비밀번호 확인이 틀렸습니다."
            third.constant = 45
            return false
        } else {
            // 모든 테스트 통과
            third.constant = 30
            password_chk_chk.isHidden = false
            password_chk_warn_stack.isHidden = true
            return true
        }
    }

    
    func isValidEmailAddress(email: String) -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    
    // 다음 버튼 활성화 확인
    func next_chk() {
        if snd_box_clk == 1 && fst_box_clk == 1 {
            if !mail_field.text!.isEmpty && !password_field.text!.isEmpty && !password_chk_field.text!.isEmpty {
                next_but.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
                next_but.isEnabled = true
                return
            }
            
        } else {
            next_but.backgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
            next_but.isEnabled = false
        }
    }

    
    // 이메일 중복 체크 get
    func get_email_isOverlap(completionHandler: @escaping (Bool) -> Void) {
        let urlstr = Api.url + "users?email=" + mail_field.text!
        let encoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(URL(string: encoded)!, headers: Api.authorization).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? "")
                print(json)
                if response.response?.statusCode == 200 {
                    print("mail 중복 성공")
                    let arr = json["users"].arrayValue
                    if arr.count == 1 { completionHandler(true) }
                    else { completionHandler(false) }
                } else {
                    self.showalert(message: "서버 오류", can: 0)
                }
                
            } else {
                self.showalert(message: "네트워크 연결 실패", can: 0)
            }
        }
    }
}

extension Register_first: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        next_chk()
        switch textField {
        case mail_field:
            mail_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        case password_field:
            password_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        default:
            password_chk_under.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        }
    }
    
    // 텍스트 필드 수정 누르면 언더라인 색 변경
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mail_field {
            mail_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        } else if textField == password_field {
            password_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        } else {
            password_chk_under.backgroundColor = UIColor(red:0.91, green:0.08, blue:0.41, alpha:1.0)
        }
    }
}
