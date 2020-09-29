//
//  CreatePostViewController.swift
//  Zealous
//
//  Created by Hannah Shiple on 9/29/20.
//

import Foundation
import UIKit
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CreatePostViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var PostTitle: UITextField!
    @IBOutlet weak var PostTopic: UITextField!
    @IBOutlet weak var PostCaption: UITextField!
    @IBOutlet weak var PostImage: UIImageView!
    
    
    var db: Firestore!
    var storage: Storage!
    var userID = Auth.auth().currentUser!.uid
    //var userID = UUID().uuidString
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        userID = Auth.auth().currentUser!.uid
    }

    
    @IBAction func UploadImage(_ sender: Any) {
    }
    
    @IBAction func SubmitPost(_ sender: Any) {
        let postTitle = PostTitle.text ?? ""
        let postTopic = PostTopic.text ?? ""
        let postCaption = PostCaption.text ?? ""
        let postImage = PostImage.image ?? nil
        
        if (postTitle == "" || postTopic == "" || postCaption == "") {
            let alertController = UIAlertController(title: "Error", message: "Please complete all fields before submitting pos.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        
        
        
    }
    
    
    
    


}
