//
//  LoginViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/27/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore

class LoginViewController: UIViewController {
    let bannerDisplayTime = 3.0
    @IBOutlet weak var usernameOrEmailField: UITextField!
    var db: Firestore!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        usernameOrEmailField.keyboardType = .emailAddress
        let settings = FirestoreSettings();
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    func showAndFocus(banner : Banner, field: UITextField){
        banner.show(duration: bannerDisplayTime)
        field.becomeFirstResponder()
        
    }
    
    @IBAction func onLogin(_ sender: Any) {
        // Error Banners
        let noMatchPassBanner = Banner(title: "Your passwords doesn't match!", subtitle: "Enter your correct password and try again.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noMatchPassBanner.dismissesOnTap = true
        let noUserBanner = Banner(title: "No User Found", subtitle: "Ensure your username or email and password is correct.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noUserBanner.dismissesOnTap = true
        let noEmailBanner = Banner(title: "Invalid email address", subtitle: "Ensure your email is entered correct.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        noEmailBanner.dismissesOnTap = true
        
        let usernameOrEmail = usernameOrEmailField.text ?? ""
        let pass = passwordField.text ?? ""
        
        if(usernameOrEmail.contains("@")){
            //contains @ then is email address
            Auth.auth().signIn(withEmail: usernameOrEmail, password: pass) { (authResult, error) in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                        case .wrongPassword:
                            // Error: The password is incorrect
                            print("wrong password")
                            self.showAndFocus(banner: noMatchPassBanner, field: self.passwordField)
                            return
                        case .invalidEmail:
                            // Error: Indicates the email address is malformed.
                            print("wrong email")
                            self.showAndFocus(banner: noEmailBanner, field: self.usernameOrEmailField)
                            return
                        case .userNotFound:
                            // no user
                            print("no such user")
                            self.showAndFocus(banner: noUserBanner, field: self.passwordField)
                            return
                        default:
                            print("Error: \(error.localizedDescription)")
                            self.showAndFocus(banner: noUserBanner, field: self.passwordField)
                            return
                    }
                } else {
                    print("User signs in successfully")
                    self.performSegue(withIdentifier: "toTimeline", sender: self)
                }
            }
            
        } else {
            //do username auth once bound username to email, tbd
            db.collection("users").getDocuments() {
                (queryCollection, error) in
                if let err = error{
                    let banner = Banner(title: "Something went wrong!", subtitle: "There was an error in querying the posts from the server.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
                    print(err.localizedDescription)
                    banner.show(duration: self.bannerDisplayTime)
                    return;
                } else {
                    //successful pull, get email address and attempt login with email address;
                    var foundDoc: QueryDocumentSnapshot? = nil;
                    for document in queryCollection!.documents {
                        if(document.get("username") as? String == self.usernameOrEmailField.text){
                            foundDoc = document;
                            break
                        }
                    }
                    
                    
                    if (foundDoc == nil){
                        
                        //document wasn't found, no
                        //user with the given username
                        
                        let banner = Banner(title: "No user found!", subtitle: "Your username couldn't be found.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
                        banner.show(duration: self.bannerDisplayTime)
                        return;
                    } else {
                        let associatedEmail = foundDoc?.get("email")
                        
                        Auth.auth().signIn(withEmail: associatedEmail as! String, password: self.passwordField.text!) { (authResult, error) in
                            if let error = error as NSError? {
                                switch AuthErrorCode(rawValue: error.code) {
                                    case .wrongPassword:
                                        // Error: The password is incorrect
                                        print("wrong password")
                                        self.showAndFocus(banner: noMatchPassBanner, field: self.passwordField)
                                        return
                                    case .invalidEmail:
                                        // Error: Indicates the email address is malformed.
                                        print("wrong email")
                                        self.showAndFocus(banner: noEmailBanner, field: self.usernameOrEmailField)
                                        return
                                    case .userNotFound:
                                        // no user
                                        print("no such user")
                                        self.showAndFocus(banner: noUserBanner, field: self.passwordField)
                                        return
                                    default:
                                        print("Error: \(error.localizedDescription)")
                                        self.showAndFocus(banner: noUserBanner, field: self.passwordField)
                                        return
                                }
                            } else {
                                print("User signs in successfully")
                                self.performSegue(withIdentifier: "toTimeline", sender: self)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        performSegue(withIdentifier: "toHome", sender: self)
    }
    
}
