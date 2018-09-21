//
//  Register_last.swift
//  GamePicker
//
//  Created by 정현민 on 2018. 9. 21..
//  Copyright © 2018년 정현민. All rights reserved.
//

import UIKit
import Firebase

class Register_last: UIViewController {
    
    @IBOutlet var next_but_o: UIButton!
    @IBOutlet var hello: UILabel!
    
    let User = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        next_but_o.layer.cornerRadius = 5
        hello.text = (User?.name)! + " 님"
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = User?.name
        changeRequest?.commitChanges { (error) in }
        
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil { return }
        }
        
    }
    
    @IBAction func next_but_o(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
