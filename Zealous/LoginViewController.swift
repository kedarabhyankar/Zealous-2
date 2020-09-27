//
//  LoginViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/27/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameOrEmailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        usernameOrEmailField.keyboardType = .emailAddress
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let usernameOrEmail = usernameOrEmailField.text ?? ""
        let pass = passwordField.text ?? ""
        
        if(usernameOrEmail.contains("@")){
            //contains @ then is email address
            Auth.auth().signIn(withEmail: usernameOrEmail, password: pass, completion: { authResult,error  in
                if(error != nil){
                    _ = AuthErrorCode(rawValue: error!._code)
                    //assume no error handling for now
                    return
                }
            })
            performSegue(withIdentifier: "toTimeline", sender: self)
        } else {
            //do username auth once bound username to email, tbd
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
    }

}
