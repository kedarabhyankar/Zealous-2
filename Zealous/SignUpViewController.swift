//
//  SignUpViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth


class SignUpViewController: UINavigationController {
    
    let bannerDisplayTime = 3.0
    var db : Firestore!
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
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
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
        
        let invalidFirstNameBanner = Banner(title: "You have invalid characters in your first name!", subtitle: "Make sure your first name is composed of only letters and dashes!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        invalidFirstNameBanner.dismissesOnTap = true
        
        let invalidLastNameBanner = Banner(title: "You have invalid characters in your last name!", subtitle: "Make sure your last name is composed of only letters and dashes!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        invalidLastNameBanner.dismissesOnTap = true
        
        let usedUsernameBanner = Banner(title: "You have entered a username that is already being used.", subtitle: "Perhaps you meant to Sign In?", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        usedUsernameBanner.dismissesOnTap = true
        
        let tooShortPassBanner = Banner(title: "Your password is too weak!", subtitle: "Your password must be greater than or equal to 6 characters at a minimum!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        tooShortPassBanner.dismissesOnTap = true
        
        let noDigitPassBanner = Banner(title: "Password error!", subtitle: "Your password must contain at least one digit!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        noDigitPassBanner.dismissesOnTap = true
        
        let noUpperPassBanner = Banner(title: "Password error!", subtitle: "Your password must contain at least one uppercase character!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        noUpperPassBanner.dismissesOnTap = true
        
        let noLowerPassBanner = Banner(title: "Password error!", subtitle: "Your password must contain at least one lowercase character!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        noLowerPassBanner.dismissesOnTap = true
        
        let noSpecialPassBanner = Banner(title: "Password error!", subtitle: "Your password must contain at least one special character!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        noSpecialPassBanner.dismissesOnTap = true
        
        let usedEmailBanner = Banner(title: "The email you entered was already linked to another account.", subtitle: "Perhaps you meant to Sign In?", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        usedEmailBanner.dismissesOnTap = true
        
        let invalidEmailBanner = Banner(title: "The email you entered was invalid.", subtitle: "Something seems to be wrong with the email address you entered...", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        invalidEmailBanner.dismissesOnTap = true
        
        let unknownErrorBanner = Banner(title: "Something went wrong!", subtitle: "An unknown error occurred.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unknownErrorBanner.dismissesOnTap = true
        
        let successBanner = Banner(title: "Successfully signed up!", subtitle: "Just a minute...", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)
        successBanner.dismissesOnTap = true
        
        
        if(firstName == ""){
            showAndFocus(banner: emptyFirstNameBanner, field: firstNameField)
            return
        }
        if(lastName == ""){
            showAndFocus(banner: emptyLastNameBanner, field: lastNameField)
            return
        }
        if(email == ""){
            showAndFocus(banner: emptyEmailBanner, field: emailField)
            return
        }
        if(username == ""){
            showAndFocus(banner: emptyUsernameBanner, field: usernameField)
            return
        }
        if(password == ""){
            showAndFocus(banner: emptyPasswordBanner, field: passwordField)
            return
        }
        if(passConf == ""){
            showAndFocus(banner: emptyConfPassBanner, field: passConfField)
            return
        }
        
        let verifyPassTuple = verifyPasswordStrength(password: password)
        if(!verifyPassTuple.0){
            
            if(verifyPassTuple.1 == "length"){
                showAndFocus(banner: tooShortPassBanner, field: passwordField)
                return;
            } else if(verifyPassTuple.1 == "digit"){
                showAndFocus(banner: noDigitPassBanner, field: passwordField)
                return;
            } else if(verifyPassTuple.1 == "upper"){
                showAndFocus(banner: noUpperPassBanner, field: passwordField)
                return;
            } else if(verifyPassTuple.1 == "lower"){
                showAndFocus(banner: noLowerPassBanner, field: passwordField)
                return;
            } else if(verifyPassTuple.1 == "special"){
                showAndFocus(banner: noSpecialPassBanner, field: passwordField)
                return;
            }
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if(error != nil){
                //some error happened, let's show the appropriate banner
                let e = error!
                let errCode = AuthErrorCode(rawValue: e._code)
                switch(errCode){
                    case .emailAlreadyInUse:
                        usedEmailBanner.show(duration: self.bannerDisplayTime)
                        self.emailField.becomeFirstResponder()
                    case .invalidEmail:
                        invalidEmailBanner.show(duration: self.bannerDisplayTime)
                        self.emailField.becomeFirstResponder()
                    default:
                        unknownErrorBanner.show(duration: self.bannerDisplayTime)
                }
            } else {
                print("Successfully made a new user!")
                successBanner.show(duration: self.bannerDisplayTime)
            }
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
    
    func verifyPasswordStrength(password: String) -> (Bool, String) {
        if(password.count < 8){
            return (false, "length")
        }
        //this regex tests for 8 characters at minimum, contains
        //a digit, uppercase, and lowercase characters
        //(?=.*[a-z])(?=.*[A-Z])(?=.*[$|#|@|!|%])(?=.*[a-zA-Z]).{8,}$
        
        let digitRegex = ".*\\d*."
        let upperRegex = ".*[A-Z]*."
        let lowerRegex = ".*[a-z]*."
        let specialRegex = ".*[$|#|@|!|%]*."
        
        let digitRegexMatcher = NSPredicate(format: "SELF MATCHES %@", digitRegex)
        let upperRegexMatcher = NSPredicate(format: "SELF MATCHES %@", upperRegex)
        let lowerRegexMatcher = NSPredicate(format: "SELF MATCHES %@", lowerRegex)
        let specialRegexMatcher = NSPredicate(format: "SELF MATCHES %@", specialRegex)

        if(!digitRegexMatcher.evaluate(with: password)){
            return (false, "digit")
        }
        if(!upperRegexMatcher.evaluate(with: password)){
            return (false, "upper")
        }
        if(!lowerRegexMatcher.evaluate(with: password)){
            return (false, "lower")
        }
        if(!specialRegexMatcher.evaluate(with: password)){
            return (false, "special")
        }
        
        return (true, "")
    }
    
}
