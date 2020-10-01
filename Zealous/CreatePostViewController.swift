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

class CreatePostViewController: UIViewController, UITextFieldDelegate {
    
    
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
        var postArray = [Post]()
        let currentPost: Post = Post.init(topic: postTopic, title: postTitle, caption: postCaption)
        postArray.append(currentPost)
        let followerArray = [User]()
        //let currentUser: User = User.getCurrentUser()
        //followerArray.append(currentUser)
        let comments = [String]()
        let numLikes: Int = 0
        var defaultImage: String = ""
        
        
        //if a field is left blank
        if (postTitle == "" || postTopic == "" || postCaption == "") {
            let alertController = UIAlertController(title: "Error", message: "Please complete all fields before submitting post.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        
        //need to check if a topic exists in the database, if it does not, need to create a new topic
        db.collection("topics").whereField("topicName", isEqualTo: postTopic).getDocuments() { (QuerySnapshot, err) in
            if QuerySnapshot?.isEmpty == true {
                //topic does not exist, so create a new topic
                print("Topic does not exist")
                self.db.collection("topics").addDocument(data: ["topicName": postTopic,  "numFollowers": followerArray.count  ])
                //create post with the new topic
                self.db.collection("posts").addDocument(data: ["topic": postTopic, "creatorId" : self.userID, "title" : postTitle, "caption" : postCaption, "img" : postImage ?? "", "likes" : numLikes, "timeStamp" : FieldValue.serverTimestamp()])
                self.PostTitle.text = ""
                self.PostTopic.text = ""
                self.PostCaption.text = ""
                return
            }
            else {
                //topic does exist, so add post to that topic's post array and add it to the database
                print("Topic does exist")
                 self.db.collection("posts").addDocument(data: ["topic": postTopic, "creatorId" : self.userID, "title" : postTitle, "caption" : postCaption, "img" : postImage ?? "", "likes" : numLikes, "timeStamp" : FieldValue.serverTimestamp()])
                self.PostTitle.text = ""
                self.PostTopic.text = ""
                self.PostCaption.text = ""
                return
            }
            
        }
       
        
        
    }
    
    
    
    


}
