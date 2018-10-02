//
//  Register_adress.swift
//  GamePicker
//
//  Created by 정현민 on 2018. 9. 21..
//  Copyright © 2018년 정현민. All rights reserved.
//
import UIKit
import Firebase

class Register_adress: UIViewController {

    @IBOutlet var hello: UILabel!
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var warn: UILabel!
    @IBOutlet var email_field: UITextField!
    
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hello.text = (User?.name)! + "님"
        warn.isHidden = true
        next_but_o.layer.cornerRadius = 5
        
        email_field.borderStyle = .none
        let border = CALayer()
        border.frame = CGRect(x: 0, y: email_field.frame.size.height-1, width: UIScreen.main.bounds.size.width-120, height: 3)
        border.backgroundColor = UIColor.red.cgColor
        email_field.layer.addSublayer((border))
        email_field.textAlignment = .center
        email_field.textColor = UIColor.black
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    @IBAction func undo(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "이메일 입력 취소", style: .default) {
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
        if email_field.text == "" {
            warn.isHidden = false
            warn.text = "어떤 글자라도 입력해주세요."
        } else if email_field.text!.count > 35 {
            warn.isHidden = false
            warn.text = "너무 길어요"
        } else {
            User?.email = email_field.text
            self.performSegue(withIdentifier: "password", sender: self)
        }
    }
    
    @objc func endEditing() {
        email_field.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        warn.isHidden = true
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 36
    }

}
