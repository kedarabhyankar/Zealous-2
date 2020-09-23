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

class ProfileSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func EditBio(_ sender: Any) {
        //replace the bio for the user in the database with new bio
        
    }
    
    @IBAction func EditProfilePic(_ sender: Any) {
        //replace the profile picture for the user in the database with the new picture
    }
    
    @IBAction func EditUsername(_ sender: Any) {
        //replace the usernmame for the user in the database with the new one and make sure no other user has the same username and it is valid
    }
    
    @IBAction func EditPassword(_ sender: Any) {
        //replace the password for the user in the database with the new one and make sure it is valid
        
    }
    
    @IBAction func EditEmail(_ sender: Any) {
        //replace the email for the user in the database with the new one and make sure it is valid
    }
    
    @IBAction func EditLang(_ sender: Any) {
        //change the language preference
    }
    
    @IBAction func EditDarkMode(_ sender: Any) {
        //turn dark mode on, light mode off
    }
    
    @IBAction func EditLightMode(_ sender: Any) {
        //turn light mode on, dark mode off
    }
    
    @IBAction func EditNotifications(_ sender: Any) {
        //turn notifications on or off
    }
    
    @IBAction func EditPrivacy(_ sender: Any) {
        //make the user profile private or public
    }
    
    @IBAction func LogOut(_ sender: Any) {
        //log the user out and send to login page
    }
    
    @IBAction func DeactivateUser(_ sender: Any) {
        //delete the user from the database and send to signup page
    }
    
}

struct ProfileSettingsViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
