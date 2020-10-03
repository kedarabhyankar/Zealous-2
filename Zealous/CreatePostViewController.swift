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
import CodableFirebase

class CreatePostViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var PostTitle: UITextField!
    @IBOutlet weak var PostTopic: UITextField!
    @IBOutlet weak var PostCaption: UITextField!
    @IBOutlet weak var PostImage: UIImageView!
    var currentUser: WriteableUser? =  nil
    var currentPost: Post? = nil
    var currentTopic: Topic? = nil
    
    
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
        WriteableUser.getCurrentUser(completion: getUser)
        Topic.getTopic(topicName: "CS", completion: getTheTopic)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
    }
    
    func getTheTopic(currentTopic: Topic) {
        self.currentTopic = currentTopic
    }
    
    
    @IBAction func UploadImage(_ sender: Any) {
    }
    
    @IBAction func SubmitPost(_ sender: Any) {
        let postTitle = PostTitle.text ?? ""
        let postTopic = PostTopic.text ?? ""
        let postCaption = PostCaption.text ?? ""
        let postImage = PostImage.image ?? nil
        // var currentPost: Post = Post.init(topic: postTopic, title: postTitle, caption: postCaption)
        let followerArray = [User]()
        //let currentUser: User = User.getCurrentUser()
        //followerArray.append(currentUser)
        let comments = [String]()
        let numLikes: Int = 0
        let defaultImage: String = ""
        
        
        //if a field is left blank
        if (postTitle == "" || postTopic == "" || postCaption == "") {
            let alertController = UIAlertController(title: "Error", message: "Please complete all fields before submitting post.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        
        //create a post object, have to add it to user's created post array and topic's post array
        self.currentPost = Post.init(topic: postTopic, title: postTitle, caption: postCaption, creatorId: currentUser!.email, img: defaultImage)
        
        //need to check if a topic exists in the database, if it does not, need to create a new topic
        db.collection("topics").whereField("title", isEqualTo: postTopic).getDocuments() { (QuerySnapshot, err) in
            if QuerySnapshot?.isEmpty == true {
                //topic does not exist, so create a new topic in database and topic object
                print("Topic does not exist")
                //create a topic object and add current post to its post array
                self.currentTopic = Topic.init(title: postTopic)
                //add new post to the user's created post array
                self.currentTopic?.addPost(post: self.currentPost!)
                self.currentUser?.addCreatedPost(post: self.currentPost!)
                let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
                self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
                
                let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
                self.db.collection("topics").document(self.currentTopic!.id).setData(dataToWrite1) { error in
                    if (error != nil) {
                        print("error writing topic to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing topic to firestore")
                    }
                }
                
                // self.db.collection("topics").document(self.currentTopic!.id).setData(["topicName": postTopic, "numFollowers": followerArray.count])
                
                let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
                self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
                    error in
                    if (error != nil) {
                        print("error writing post to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing post ot firestore")
                    }
                }
                //create post with the new topics
                // self.db.collection("posts").document(postID).setData(["topic": postTopic, "postId" : postID, "creatorId" : Auth.auth().currentUser?.email! ?? self.userID, "title" : postTitle, "caption" : postCaption, "img" : postImage ?? "", "likes" : numLikes, "timeStamp" : FieldValue.serverTimestamp()])
                self.PostTitle.text = ""
                self.PostTopic.text = ""
                self.PostCaption.text = ""
                return
            }
            else {
                //topic does exist, so add post to that topic's post array and add it to the database
                print("Topic does exist")
                //retrieve topic object and add current post to its post array
                Topic.getTopic(topicName: "CS", completion: self.getTheTopic)
                
                
                //Topic.getTopic(topicName: postTopic, completion: self.getTheTopic)
                print("current topic is: \(String(describing: self.currentTopic))")
                
                //add post to topic's array
                self.currentTopic?.addPost(post: self.currentPost!)
                //encode the updated post array
                let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
                //find the topic in the database and update post array???
                self.db.collection("topics").document(self.currentTopic!.id).setData(dataToWrite1)
                /*self.db.collection("topics").whereField("title", isEqualTo: postTopic).getDocuments() {
                    (querySnapshot, error) in
                    if let error = error {
                        print("error getting topic")
                    } else {
                        for document in querySnapshot!.documents {
                            document.setData(dataToWrite1)
                        }
                    }
                    
                }*/
                /*(["posts" : dataToWrite1]) {
                 error in
                 if (error != nil) {
                 print("error writing topic to firestore: \(String(describing: error))")
                 return
                 } else {
                 print("success writing topic ot firestore")
                 }
                 }*/
                
                //send current post to database
                let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
                self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
                    error in
                    if (error != nil) {
                        print("error writing post to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing post to firestore")
                    }
                }               // self.db.collection("posts").document(self.currentPost!.postId).setData(["topic": postTopic,"postId" : self.currentPost!.postId ,"creatorId" : Auth.auth().currentUser?.email! ?? self.userID, "title" : postTitle, "caption" : postCaption, "img" : postImage ?? "", "likes" : numLikes, "timeStamp" : FieldValue.serverTimestamp()])
                self.PostTitle.text = ""
                self.PostTopic.text = ""
                self.PostCaption.text = ""
                return
            }
            
        }
        
        
        
    }
    
    
    
    


}
