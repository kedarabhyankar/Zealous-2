//
//  LoginViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/24/20.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameEmailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLogIn(_ sender: Any) {
        let usernameOrEmail = usernameEmailField.text ?? ""
        let pass = passwordField.text ?? ""
        
        if(usernameOrEmail.contains("@")){
            //consider this an email since it contains an @ symbol
        } else {
            //not an email, its a username instead
            
        }
        
        
    }
    
    @IBAction func onBack(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
