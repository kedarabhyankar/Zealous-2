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
import EmailValidator

class SignUpViewController: UIViewController {
    
    let bannerDisplayTime = 3.0
    var db : Firestore!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passConfField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var passConf: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        self.nextButton.isEnabled = false
        [firstNameField, lastNameField, usernameField, emailField, passwordField, passConfField].forEach({ $0?.addTarget(self, action: #selector(checkFields), for: .editingChanged)})
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        firstNameField.autocorrectionType = .yes
        lastNameField.autocorrectionType = .yes
        emailField.autocorrectionType = .yes
        passwordField.autocorrectionType = .no
        passConfField.autocorrectionType = .no
        emailField.keyboardType = .emailAddress
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func checkFields(_ textField: UITextField){
        if(firstNameField.text == "" || lastNameField.text == "" || emailField.text == "" || usernameField.text == "" || passwordField.text == "" ||
            passConfField.text == ""){
            self.nextButton.isEnabled = false
        } else {
            self.nextButton.isEnabled = true
        }
    }
    
    @IBAction func onSignUpNext(_ sender: Any) {
        firstName = (firstNameField.text?.trimmingCharacters(in: .whitespaces))!
        lastName = (lastNameField.text?.trimmingCharacters(in: .whitespaces))!
        email = (emailField.text?.trimmingCharacters(in: .whitespaces))!
        username = (usernameField.text?.trimmingCharacters(in: .whitespaces))!
        password = (passwordField.text?.trimmingCharacters(in: .whitespaces))!
        passConf = (passConfField.text?.trimmingCharacters(in: .whitespaces))!
        
        var goodFirstName = true
        var goodLastName = true
        var goodEmail = true
        var goodUsername = true
        var goodPass = true
        var matchPass = true
        
        
        
        //define banners
        let invalidFirstNameBanner = Banner(title: "You have invalid characters in your first name!", subtitle: "Make sure your first name is composed of only letters and dashes!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        invalidFirstNameBanner.dismissesOnTap = true
        
        let invalidLastNameBanner = Banner(title: "You have invalid characters in your last name!", subtitle: "Make sure your last name is composed of only letters and dashes!", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
        invalidLastNameBanner.dismissesOnTap = true
        
        let noMatchPassBanner = Banner(title: "Your passwords must match!", subtitle: "Your passwords don't seem to match. Try again.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noMatchPassBanner.dismissesOnTap = true
        
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
        
        let successBanner = Banner(title: "Great!", subtitle: "We need just a few more details about you...", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)
        successBanner.dismissesOnTap = true
        //end define banners
        
        
        //begin check first and last name
        if(!verifyName(name: firstName)){
            goodFirstName = false
            showAndFocus(banner: invalidFirstNameBanner, field: firstNameField)
            self.nextButton.isSelected = false
            return
        }
        
        if(!verifyName(name: lastName)){
            goodLastName = false
            showAndFocus(banner: invalidLastNameBanner, field: lastNameField)
            self.nextButton.isSelected = false
            return
        }
        
        //begin email check
        if(!EmailValidator.validate(email: email, allowTopLevelDomains: true, allowInternational: true)){
            goodEmail = false
            self.nextButton.isSelected = false
            return
        }
        //check password strength
        
        let verifyPassTuple = verifyPasswordStrength(password: password)
        if(!verifyPassTuple.0){
            
            if(verifyPassTuple.1 == "length"){
                showAndFocus(banner: tooShortPassBanner, field: passwordField)
                self.nextButton.isSelected = false
                goodPass = false
                return
            } else if(verifyPassTuple.1 == "digit"){
                showAndFocus(banner: noDigitPassBanner, field: passwordField)
                self.nextButton.isSelected = false
                goodPass = false
                return
            } else if(verifyPassTuple.1 == "upper"){
                showAndFocus(banner: noUpperPassBanner, field: passwordField)
                self.nextButton.isSelected = false
                goodPass = false
                return
            } else if(verifyPassTuple.1 == "lower"){
                showAndFocus(banner: noLowerPassBanner, field: passwordField)
                self.nextButton.isSelected = false
                goodPass = false
                return
            } else if(verifyPassTuple.1 == "special"){
                showAndFocus(banner: noSpecialPassBanner, field: passwordField)
                self.nextButton.isSelected = false
                goodPass = false
                return
            }
        }
        
        if(password != passConf){
            showAndFocus(banner: noMatchPassBanner, field: passConfField)
            self.nextButton.isSelected = false
            matchPass = false
            return
        }
        
        var usernameTaken : Bool = false;
        //verify username doesn't already exist in database
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                unknownErrorBanner.show(duration: self.bannerDisplayTime)
                self.nextButton.isSelected = false
                goodUsername = false
                return
            } else {
                for document in querySnapshot!.documents {
                    if(document.get("username") as? String == self.username){
                        usernameTaken = true;
                        break;
                    }
                }
            }
        }
        
        if(usernameTaken){
            showAndFocus(banner: usedUsernameBanner, field: usernameField)
            self.nextButton.isSelected = false
            goodUsername = false
            return
        }
        
        if(goodFirstName && goodLastName && goodUsername && goodEmail && goodPass && matchPass){
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if(error != nil){
                    //some error happened, let's show the appropriate banner
                    let e = error!
                    let errCode = AuthErrorCode(rawValue: e._code)
                    switch(errCode){
                        case .emailAlreadyInUse:
                            usedEmailBanner.show(duration: self.bannerDisplayTime)
                            self.emailField.becomeFirstResponder()
                            self.nextButton.isSelected = false
                            break
                        case .invalidEmail:
                            invalidEmailBanner.show(duration: self.bannerDisplayTime)
                            self.emailField.becomeFirstResponder()
                            self.nextButton.isSelected = false
                            break
                        default:
                            unknownErrorBanner.show(duration: self.bannerDisplayTime)
                            self.nextButton.isSelected = false
                            break
                    }
                    return
                } else {
                    //no errors, so segue through
                    print("segue-ing...")
                    successBanner.show(duration: self.bannerDisplayTime)
                    self.performSegue(withIdentifier: "toEmailVerify", sender: self)
                }
            }
        }
    }
    
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
    
    func verifyName(name: String) -> Bool {
        if(name.count == 0){
            return false
        }
        
        for char in name {
            if(!char.isLetter && char != "-"){
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toEmailVerify"){
            if let destVC = segue.destination as? VerifyEmailViewController {
                destVC.intermediaryUser = Profile(firstName: firstName, lastName: lastName, username: username, email: email)
            }
        }
    }
    
}
