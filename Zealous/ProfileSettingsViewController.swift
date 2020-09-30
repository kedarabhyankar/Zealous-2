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


class ProfileSettingsViewController: UITableViewController, UITextFieldDelegate {

    

    @IBOutlet weak var ChangeFName: UITextField!

    @IBOutlet weak var ChangeLName: UITextField!

    @IBOutlet weak var ChangeBio: UITextField!

    @IBOutlet weak var ChangeEmail: UITextField!

    @IBOutlet weak var ChangeUsername: UITextField!

    @IBOutlet weak var CurrPassword: UITextField!

    @IBOutlet weak var NewPassword: UITextField!

    @IBOutlet weak var ConfirmPassword: UITextField!

    var db: Firestore!

    var storage: Storage!

    var userID = Auth.auth().currentUser!.uid

    //var userID = UUID().uuidString

    override func viewDidLoad() {

        super.viewDidLoad()

        CurrPassword.isSecureTextEntry = true        // Do any additional setup after loading the view

        NewPassword.isSecureTextEntry = true

        ConfirmPassword.isSecureTextEntry = true

        ChangeEmail.keyboardType = .emailAddress

        let firestoreSettings = FirestoreSettings()

        Firestore.firestore().settings = firestoreSettings

        db = Firestore.firestore()

        storage = Storage.storage()

        userID = Auth.auth().currentUser!.uid

    }

    

    

    @IBAction func SubmitUserSettings(_ sender: Any) {

        //print("user id is: " + userID)

        let fname = ChangeFName.text ?? ""

        if (fname != "") {

        db.collection("users").document("iF32TJTlPALTtg1o7MiE").updateData(["firstName":fname ])

        ChangeFName.text = ""

        }

        let lname: String = ChangeLName.text ?? ""

        if (lname != "") {

        db.collection("users").document("iF32TJTlPALTtg1o7MiE").updateData(["lastName": lname])

        ChangeLName.text = ""

        }

        let changeBio: String = ChangeBio.text ?? ""

        if (changeBio != "") {

        db.collection("users").document("iF32TJTlPALTtg1o7MiE").updateData(["bio": changeBio])

        ChangeBio.text = ""

        }

        let email: String = ChangeEmail.text ?? ""

        if (email != "") {

            db.collection("users").document("iF32TJTlPALTtg1o7MiE").updateData(["email": email])

            Auth.auth().currentUser?.updateEmail(to: email) { (error) in

                    if let error = error {

                        print("Can't update email, error:  \(error)")

                    } else {

                        print("Updated email sucess")

                    }

            }

            ChangeEmail.text = ""

        }

        let username: String = ChangeUsername.text ?? ""

        if (username != "") {

            db.collection("users").document(userID).updateData(["profile.username": username])

            ChangeUsername.text = ""

        }

    }

    

    

    

    

    @IBAction func SubmitPassword(_ sender: Any) {

        let newPass: String = NewPassword.text ?? ""

        let currentPass: String = CurrPassword.text ?? ""

        let confirmPass: String = ConfirmPassword.text ?? ""

        var reauth: Bool =  false

        let email: String = (Auth.auth().currentUser?.email)!

        //let email: String = db.collection("users").document(userID).value(forKey: "email") as! String

        let creds = EmailAuthProvider.credential(withEmail: email, password: currentPass)

        //reauthenticate the user with the current password they entered and make sure it is correct

        Auth.auth().currentUser?.reauthenticate(with: creds, completion: { (result, error) in

            if let error = error {

            let alertController = UIAlertController(title: "\(error)", message: "Current password is incorrect.", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            self.present(alertController, animated: true, completion: nil)

            self.CurrPassword.text = ""

            self.NewPassword.text = ""

            self.ConfirmPassword.text = ""

            //return

            }

            else {

            //start of reauth being true

                reauth = true

                //self.CurrPassword.text = ""

                if (newPass == confirmPass && newPass != "" && confirmPass != "" && reauth == true) {

                    let regex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z]).{8,}$")

                    if (regex.evaluate(with: newPass) == false) {

                        let alertController = UIAlertController(title: "Error", message: "Please Enter Valid Password", preferredStyle: .alert)

                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                        alertController.addAction(defaultAction)

                        self.present(alertController, animated: true, completion: nil)

                        self.CurrPassword.text = ""

                        self.NewPassword.text = ""

                        self.ConfirmPassword.text = ""

                        return

                    }

                    Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in

                            if let error = error {

                                print("Can't update password, error:  \(error)")

                            } else {

                                let alertController = UIAlertController(title: "Sucess", message: "Password was changed.", preferredStyle: .alert)

                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                                alertController.addAction(defaultAction)

                                self.present(alertController, animated: true, completion: nil)

                                self.CurrPassword.text = ""

                                self.NewPassword.text = ""

                                self.ConfirmPassword.text = ""

                                print("Updated password sucess")

                                return

                            }

                    }

                

                } else if ( !newPass.elementsEqual(confirmPass)) {

                    let alertController = UIAlertController(title: "Error", message: "Make Sure Passwords Match", preferredStyle: .alert)

                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                    alertController.addAction(defaultAction)

                    self.present(alertController, animated: true, completion: nil)

                    self.CurrPassword.text = ""

                    self.NewPassword.text = ""

                    self.ConfirmPassword.text = ""

                    return

                }

                

           //end of reauth being true

            }

        })

        

      /*  if (newPass == confirmPass && newPass != "" && confirmPass != "" && reauth == true) {

            let regex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z]).{8,}$")

            if (regex.evaluate(with: newPass) == false) {

                let alertController = UIAlertController(title: "Error", message: "Please Enter Valid Password", preferredStyle: .alert)

                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                alertController.addAction(defaultAction)

                present(alertController, animated: true, completion: nil)

                NewPassword.text = ""

                ConfirmPassword.text = ""

                //return

            }

            Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in

                    if let error = error {

                        print("Can't update password, error:  \(error)")

                    } else {

                        self.NewPassword.text = ""

                        self.ConfirmPassword.text = ""

                        print("Updated password sucess")

                        return

                    }

            }

        

        } else if ( newPass != confirmPass) {

            let alertController = UIAlertController(title: "Error", message: "Make Sure Passwords Match", preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)

            present(alertController, animated: true, completion: nil)

            NewPassword.text = ""

            ConfirmPassword.text = ""

            //return

        } */

        

    }


    

    @IBAction func LogoutUser(_ sender: Any) {

         do {

               try Auth.auth().signOut()

               self.performSegue(withIdentifier: "toMain", sender: self)

               }

               catch let error as NSError

               {

                   print("Error logging out user" + error.localizedDescription)

               }

        

    }

    

    

    @IBAction func DeleteUser(_ sender: Any) {

        

        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)

        

        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in

            //user wants to delete their account

            let user = Auth.auth().currentUser

            self.db.collection("users").document((user?.email)!).delete()

            user?.delete { error in

                if let error = error {

                    print("Error deleting user \(error)")

                } else {

                     self.performSegue(withIdentifier: "toMain", sender: self)

                }

            }

        }))


         deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

           //user does not want to delete their account

            deleteAlert.dismiss(animated: true, completion: nil)

           }))


         present(deleteAlert, animated: true, completion: nil)

    }

    

    


    

    


/* struct ProfileSettingsViewController_Previews: PreviewProvider {

    static var previews: some View {

        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/

    }

}*/

    

}
