//
//  SignUpViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit
import FirebaseFirestore
import BRYXBanner


class SignUpViewController: UINavigationController {
    
    let bannerDisplayTime = 3.0
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passConfField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        passConfField.isSecureTextEntry = true;
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignUpNext(_ sender: Any) {
        let firstName = firstNameField.text ?? ""
        let lastName = lastNameField.text ?? ""
        let email = emailField.text ?? ""
        let username = usernameField.text ?? ""
        let password = passwordField.text ??
        ""
        let passConf = passConfField.text ??
        ""
        
        
        let emptyFirstNameBanner = Banner(title: "You can't have an empty first name!", subtitle: "Make sure you input a first name!", image: nil, backgroundColor: UIColor.red, didTapBlock:nil)
        emptyFirstNameBanner.dismissesOnTap = true
        
        let emptyLastNameBanner = Banner(title: "You can't have an empty last name!", subtitle: "Make sure you input a last name!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        emptyLastNameBanner.dismissesOnTap = true
        
        let emptyEmailBanner = Banner(title: "You can't have an empty email!", subtitle: "Make sure you input an email!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        emptyEmailBanner.dismissesOnTap = true
        
        let emptyUsernameBanner = Banner(title: "You can't have an empty username!", subtitle: "Make sure you input a username!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        emptyUsernameBanner.dismissesOnTap = true

        let emptyPasswordBanner = Banner(title: "You can't have an empty password!", subtitle: "Make sure you input a password!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        emptyPasswordBanner.dismissesOnTap = true
        
        let emptyConfPassBanner = Banner(title: "You can't have an empty confirmation of password!", subtitle: "Make sure you input a password!", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        emptyConfPassBanner.dismissesOnTap = true
        
        
        if(firstName == ""){
            showAndFocus(banner: emptyFirstNameBanner, field: firstNameField)
        }
        if(lastName == ""){
            showAndFocus(banner: emptyLastNameBanner, field: lastNameField)
        }
        if(email == ""){
            showAndFocus(banner: emptyEmailBanner, field: emailField)
        }
        if(username == ""){
            showAndFocus(banner: emptyUsernameBanner, field: usernameField)
        }
        if(password == ""){
            showAndFocus(banner: emptyPasswordBanner, field: passwordField)
        }
        if(passConf == ""){
            showAndFocus(banner: emptyConfPassBanner, field: passConfField)
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func showAndFocus(banner : Banner, field: UITextField){
        banner.show(duration: bannerDisplayTime)
        field.becomeFirstResponder()
    }
    
}
