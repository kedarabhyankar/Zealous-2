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

class CreatePostViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var PostTitle: UITextField!
    @IBOutlet weak var PostTopic: UITextField!
    @IBOutlet weak var PostCaption: UITextField!
    @IBOutlet weak var PostImage: UIImageView!
    var imageExt: String?
    var image: UIImage?
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
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
    }
    
    func getTheTopic(currentTopic: Topic) {
        DispatchQueue.main.async {
            self.currentTopic = currentTopic
            print("current topic in getTheTopic: \(String(describing: self.currentTopic)) ")
            //add post to topic's array
            self.currentTopic?.addPost(post: self.currentPost!)
            //encode the updated post array
            let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
            //find the topic in the database and update post array???
            self.db.collection("topics").document(self.currentTopic!.id).setData(dataToWrite1)
            
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
            }
            
            self.currentUser?.addCreatedPost(post: self.currentPost!)
            let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
            self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
            
            self.PostTitle.text = ""
            self.PostTopic.text = ""
            self.PostCaption.text = ""
            self.PostImage.image = nil
            return
        }
        // self.currentTopic = currentTopic
        
    }
    
    @IBAction func UploadImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        PostImage.image = self.image
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage
        if let possibleImage = info[.editedImage] as? UIImage{
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        } else {
            return;
        }
        self.image = image
        self.PostImage.image = image
        self.imageExt = ".png"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SubmitPost(_ sender: Any) {
        let postTitle = PostTitle.text ?? ""
        let postTopic = PostTopic.text ?? ""
        let postCaption = PostCaption.text ?? ""
        let postImage = PostImage.image ?? nil
        let followerArray = [User]()
        let comments = [String]()
        let numLikes: Int = 0
        let defaultImage: String = ""
        
        
        //if a field is left blank
        if (postTitle == "" || postTopic == "" || postCaption == "") {
            let alertController = UIAlertController(title: "Error", message: "Please complete all fields before submitting post.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            self.PostTitle.text = ""
            self.PostTopic.text = ""
            self.PostCaption.text = ""
            self.PostImage.image = nil
            return;
        }
        // create a post object, have to add it to user's created post array and topic's post array
        self.currentPost = Post.init(topic: postTopic, title: postTitle, caption: postCaption, creatorId: currentUser!.email, img: defaultImage)
        
        // need to check if a topic exists in the database, if it does not, need to create a new topic
        let db = Firestore.firestore()
        let topicRef = db.collection("topics").document(postTopic)
        
        topicRef.getDocument { document, error in
            if let document = document {
                if document.data() == nil {
                    print("Topic does not exist")
                    print("Topic does not exist")
                    //create a topic object and add current post to its post array
                    self.currentTopic = Topic.init(title: postTopic)
                    self.currentTopic?.addPost(post: self.currentPost!)
                    
                    let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
                    db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1) { error in
                        if (error != nil) {
                            print("error writing topic to firestore: \(String(describing: error))")
                            return
                        } else {
                            print("success writing topic to firestore")
                        }
                    }
                    self.afterTopicCreated()
                    return
                }
                var model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                print("Model: \(model)")
                model.addPost(post: self.currentPost!)
                
                let dataToWrite1 = try! FirestoreEncoder().encode(model)
                db.collection("topics").document(model.title).setData(dataToWrite1) { error in
                    if (error != nil) {
                        print("error writing topic to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing topic to firestore")
                    }
                }
                
                self.afterTopicCreated()
            } else {
                print("Topic does not exist")
                //create a topic object and add current post to its post array
                self.currentTopic = Topic.init(title: postTopic)
                self.currentTopic?.addPost(post: self.currentPost!)
                
                let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
                db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1) { error in
                    if (error != nil) {
                        print("error writing topic to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing topic to firestore")
                    }
                }
                self.afterTopicCreated()
            }
        }
    }
    
    func afterTopicCreated() {
        //add new post to the user's created post array
         self.currentUser?.addCreatedPost(post: self.currentPost!)
         let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
         db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
         
         // write post to db
         let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
         db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
             error in
             if (error != nil) {
                 print("error writing post to firestore: \(String(describing: error))")
                 return
             } else {
                 print("success writing post ot firestore")
             }
         }
    }
 
        //
        //        db.collection("topics").whereField("title", isEqualTo: postTopic).getDocuments() { (QuerySnapshot, err) in
        //            if QuerySnapshot?.isEmpty == true {
        //                //topic does not exist, so create a new topic in database and topic object
        //                print("Topic does not exist")
        //                //create a topic object and add current post to its post array
        //                self.currentTopic = Topic.init(title: postTopic)
        //                //add new post to the user's created post array
        //                self.currentTopic?.addPost(post: self.currentPost!)
        //                self.currentUser?.addCreatedPost(post: self.currentPost!)
        //                let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
        //                self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
        //
        //                let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
        //                self.db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1) { error in
        //                    if (error != nil) {
        //                        print("error writing topic to firestore: \(String(describing: error))")
        //                        return
        //                    } else {
        //                        print("success writing topic to firestore")
        //                    }
        //                }
        //
        //
        //                let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
        //                self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
        //                    error in
        //                    if (error != nil) {
        //                        print("error writing post to firestore: \(String(describing: error))")
        //                        return
        //                    } else {
        //                        print("success writing post ot firestore")
        //                    }
        //                }
        //                //create post with the new topics
        //                // self.db.collection("posts").document(postID).setData(["topic": postTopic, "postId" : postID, "creatorId" : Auth.auth().currentUser?.email! ?? self.userID, "title" : postTitle, "caption" : postCaption, "img" : postImage ?? "", "likes" : numLikes, "timeStamp" : FieldValue.serverTimestamp()])
        //                self.PostTitle.text = ""
        //                self.PostTopic.text = ""
        //                self.PostCaption.text = ""
        //                self.PostImage.image = nil
        //                return
        //            }
        //            else {
        //                //topic does exist, so add post to that topic's post array and add it to the database
        //                print("Topic does exist")
        //                //retrieve topic object and add current post to its post array
        //                //Topic.getTopic(topicName: "CS", completion: self.getTheTopic)
        //                DispatchQueue.main.async() {
        //                    print("arg: " + postTopic)
        //                    Topic.getTopic(topicName: postTopic, completion: self.getTheTopic)
        //                }
        //                print("current topic in submit post: \(String(describing: self.currentTopic))")
        //
        //                //add post to topic's array
        //                //self.currentTopic?.addPost(post: self.currentPost!)
        //                //encode the updated post array
        //                //let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
        //                //find the topic in the database and update post array???
        //                //self.db.collection("topics").document(self.currentTopic!.id).setData(dataToWrite1)
        //
        //                //send current post to database
        //                //let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
        //               /* self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
        //                    error in
        //                    if (error != nil) {
        //                        print("error writing post to firestore: \(String(describing: error))")
        //                        return
        //                    } else {
        //                        print("success writing post to firestore")
        //                    }
        //                }
        //                self.PostTitle.text = ""
        //                self.PostTopic.text = ""
        //                self.PostCaption.text = ""*/
        //
        //                return
        //
        //            }
        //
        //        }
}
