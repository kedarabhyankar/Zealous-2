//
//  DeletePostViewController.swift
//  Zealous
//
//  Created by Hannah Shiple on 10/5/20.
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
import BRYXBanner

class DeletePostViewController: UIViewController, UITextFieldDelegate {
    
    
    var currentTopic: Topic? = nil
    var currentUser: WriteableUser? = nil
    var currentPost: Post? = nil
    var db: Firestore =  Firestore.firestore()
    var storage: Storage = Storage.storage()
    
    
     override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view
           let firestoreSettings = FirestoreSettings()
           Firestore.firestore().settings = firestoreSettings
           //db = Firestore.firestore()
           //storage = Storage.storage()
           WriteableUser.getCurrentUser(completion: getUser)
       }
    
    func getUser(currentUser: WriteableUser) {
            self.currentUser = currentUser
            self.currentUser?.deleteCreatedPost(postId: self.currentPost!.postId)
            let dataToWrite2 = try! FirestoreEncoder().encode(self.currentUser)
            self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite2)
    }
    
    func getTheTopic (currentTopic: Topic) {
        DispatchQueue.main.async {
            self.currentTopic = currentTopic
            //remove the post from the topic's post array and send to firestore
            self.currentTopic?.removePost(postId: self.currentPost!.postId)
            //if topic only had one post, delete the topic
            if (self.currentTopic?.posts.count == 0) {
                //topic's post array now has zero posts
                Topic.deleteTopic(topicName: self.currentTopic!.title)
                return
            }
            //else send the updated topic object to the database
            let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
            self.db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1) {
                error in
                if (error != nil) {
                    print("error writing topic to firestore: \(String(describing: error))")
                    return
                } else {
                    print("success writing topic to firestore")
                }
            }
        }
    }
    
    func getThePost (currentPost: Post) {
        self.currentPost = currentPost
        DeletePostId(thePost: self.currentPost!)
    }
    
    @IBAction func DeletePost(_ sender: Any) {
        Post.getPost(postId: "E7EEA429-0759-4753-A7C6-657F5CF700B9", completion: getThePost)
        //call delete post id and then refresh the screen
        //self.performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    func DeletePostId (thePost: Post) {
        //delete a post given it's post ID
        DispatchQueue.main.async {
            //delete post from topic's post array and send topic object back to database
            WriteableUser.getCurrentUser(completion: self.getUser)
            Topic.getTopic(topicName: thePost.topic, completion: self.getTheTopic)
            //delete post from user's created posts array and send user object back to databse
            Post.deletePost(postId: thePost.postId)
            //delete post document from database
            /*self.db.collection("posts").document(thePost.postId).delete() {
                error in
                if (error != nil) {
                    print("error deleting post from firestore: \(String(describing: error))")
                    return
                } else {
                    print("success deleting post from firestore")
                }
            } */
        }
        print("the post is: \(thePost)")
        /* self.db.collection("posts").document(thePost.postId).delete() {
            error in
            if (error != nil) {
                print("error deleting post from firestore: \(String(describing: error))")
                return
            } else {
                print("success deleting post from firestore")
            }
        } */
        
        return
    }
    
    
    
    
}
