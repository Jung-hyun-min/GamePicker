//
//  Register_sex.swift
//  GamePicker
//
//  Created by 정현민 on 2018. 9. 21..
//  Copyright © 2018년 정현민. All rights reserved.
//

import UIKit

class Register_sex: UIViewController {

    @IBOutlet var hello: UILabel!
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var sex: UISegmentedControl!
    
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        next_but_o.layer.cornerRadius = 5
        hello.text = (User?.name)! + "님"
    }
    
    @IBAction func undo(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "계속", style: .cancel)
        let ok = UIAlertAction(title: "이름 다시입력", style: .default) {
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
        if sex.selectedSegmentIndex == 0 {
            User?.sex = 1//M
        } else {
            User?.sex = 2//W
        }
        performSegue(withIdentifier: "adress", sender: self)
    }
    
}
