//
//  ProfileSettingsController.swift
//  Zealous
//
//  Created by Hannah Shiple on 9/17/20.
//

import UIKit
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ProfileSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var InputText : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    let db = Firestore.firestore();
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    @IBAction func FirstName(_ sender: UITextField) {
        InputText.delegate = self
        let fname: String = InputText.text!
        let _: Void = db.collection("users").document(userID).updateData(["FirstName":fname ])
    }
    
    
    @IBAction func LastName(_ sender: Any) {
        InputText.delegate = self
        let lname: String = InputText.text!
        let _: Void = db.collection("users").document(userID).updateData(["LastName": lname])
    }
    
    @IBAction func PhoneNumber(_ sender: Any) {
        InputText.delegate = self
        let phonenum: String = InputText.text!
        let _: Void = db.collection("users").document(userID).updateData(["PhoneNumber": phonenum])    }
    
    @IBAction func ChangeEmail(_ sender: Any) {
        InputText.delegate = self
        let email: String = InputText.text!
        let _: Void = db.collection("users").document(userID).updateData(["profile.email": email])
        //also use AUTH to update email
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if let error = error {
                    print("Can't update email, error:  \(error)")
                } else {
                    print("Updated password sucess")
                }
        }
    }
    
    @IBAction func ChangeUsername(_ sender: Any) {
        InputText.delegate = self
        _ = db.collection("users").whereField("id", isEqualTo:userID)
        var _: AuthCredential
        let username: String = InputText.text!
        _ = Auth.auth().currentUser
        let _: Void = db.collection("users").document(userID).updateData(["profile.username": username])
    }
    
    var newPass: String = ""
    @IBAction func NewPassword(_ sender: Any) {
        InputText.delegate = self
        let regex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z]).{8,}$")
        if (newPass == "" || regex.evaluate(with: newPass) == false) {
            let alertController = UIAlertController(title: "Error", message: "Please Enter Valid Password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        newPass = InputText.text!
    }
    
    var confirmPass: String = ""
    @IBAction func ConfirmPassword(_ sender: Any) {
        InputText.delegate = self
        let regex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$|#|@|!|%]).{8,}$")
        if (confirmPass == "" || regex.evaluate(with: confirmPass) == false) {
            let alertController = UIAlertController(title: "Error", message: "Please Enter Valid Password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        confirmPass = InputText.text!
    }
    
    
    @IBAction func ChangePassword(_ sender: Any) {
        if (newPass != confirmPass) {
            //send error message
            let alertController = UIAlertController(title: "Error", message: "Make Sure Passwords Match", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        InputText.delegate = self
       // _ = db.collection("users").whereField("id", isEqualTo:userID)
        //var _: AuthCredential
        //let pass: String = InputText.text!
        //_ = Auth.auth().currentUser
       // let _: Void = db.collection("users").document(userID).updateData(["profile.password":pass])
        Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in
            if let error = error {
                print("Can't update password, error:  \(error)")
            } else {
                print("Updated password sucess")
            }
    }
    
}
    
    @IBAction func Logout(_ sender: Any) {
        do {
        try Auth.auth().signOut()
        let storyboard = UIStoryboard(name:"Main", bundle:nil )
        let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
        self.present(vc, animated: true, completion: nil)
        }
        catch let error as NSError
        {
            print("Error logging out user" + error.localizedDescription)
        }
        
    }
    
    @IBAction func DeleteUser(_ sender: Any) {

        let alert2 = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)
        alert2.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                alert2.dismiss(animated: true, completion: nil)
        }))
            alert2.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { (action) in
                let user = Auth.auth().currentUser
                let _ = self.db.collection("users").document(self.userID).delete()
                user?.delete { error in
                    if let error = error {
                        print("Error deleting user \(error)")
                    } else {
                        let storyboard = UIStoryboard(name:"Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }))
        
    }
    
    

/* struct ProfileSettingsViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}*/
    
}
