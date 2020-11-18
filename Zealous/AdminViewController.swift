//
//  AdminViewController.swift
//  Zealous
//
//  Created by Hannah Shiple on 11/12/20.
//

import Foundation
import UIKit
import FirebaseFirestore
import BRYXBanner
import FirebaseAuth
import EmailValidator

class AdminViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var logout: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let auth = Auth.auth()
        let userLog = auth.currentUser
        
        if (userLog?.email) == nil {
            back.isHidden = false
            logout.isHidden = true
        }
        else {
            back.isHidden = true
            logout.isHidden = false
        }
    }
    @IBAction func LogoutPressed(_ sender: Any) {
        do {
            
            try Auth.auth().signOut()
            
            //let storyboard = UIStoryboard(name:"Main", bundle:nil )
            
            //let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
            
            //present(vc, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "toMain", sender: self)
            
        }
            
        catch let error as NSError
            
        {
            
            print("Error logging out user" + error.localizedDescription)
            
        }
    }
    
    
    
    
}
