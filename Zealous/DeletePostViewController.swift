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
           //WriteableUser.getCurrentUser(completion: getUser)
           storage = Storage.storage()
       }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        print("current user in delete post controller is: \(String(describing: self.currentUser))")
        self.currentUser?.deleteCreatedPost(postId: self.currentPost!.postId)
        let dataToWrite2 = try! FirestoreEncoder().encode(self.currentUser)
        self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite2)
        
         //delete image from storage
               let ref = Storage.storage().reference()
               let imageRef = ref.child("media/" + (self.currentUser?.email)! + "/" + (self.currentPost?.title)! + "/" + "pic.jpeg")
               //let ref = Storage.storage().reference(forURL: "media/" + (self.currentUser?.email)! + "/" +  (self.currentPost?.title)! + "/" + "pic.jpeg" )
               imageRef.delete { error in
                   if let error = error {
                       print("error deleting from storage")
                   } else {
                       print("sucess deleting from storage")
                   }
               }
        Topic.getTopic(topicTitle: self.currentPost!.topic, completion: self.getTheTopic)
        
    }
    
    func getTheTopic (currentTopic: Topic) {
        self.currentTopic = currentTopic
        DispatchQueue.main.async {
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
        Post.deleteStoragePost(thePost: self.currentPost!, theUser: self.currentUser!)
        Post.deletePost(postId: self.currentPost!.postId)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    func getTheTopic2 (currentTopic: Topic) {
        self.currentTopic = currentTopic
        DispatchQueue.main.async {
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
        Post.deleteStoragePost(thePost: self.currentPost!, theUser: self.currentUser!)
        Post.deletePost(postId: self.currentPost!.postId)
    }
    
    func getThePost (currentPost: Post) {
        self.currentPost = currentPost
        if (self.currentPost == nil) {
            //cannot delete the same post twice
            print("trying to delete a post that does not exist in the database")
            let alertController = UIAlertController(title: "Error", message: "Post does not exist!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        DeletePostId(thePost: self.currentPost!)
        
    }
    
    
    func DeletePostId (thePost: Post) {
        //delete a post given it's post I
        self.currentPost = thePost
 
        let serialQueue = DispatchQueue(label: "com.queue.serial")
       
            //delete post from topic's post array and send topic object back to database
        serialQueue.sync {
        WriteableUser.getCurrentUser(completion: self.getUser)
        }
        /*serialQueue.sync {
            Topic.getTopic(topicTitle: thePost.topic, completion: self.getTheTopic)
        }
        serialQueue.sync {
            //delete post from user's created posts array and send user object back to databse
            Post.deleteStoragePost(thePost: thePost, theUser: self.currentUser!)
        }
        serialQueue.sync {
            Post.deletePost(postId: thePost.postId)
            //delete post document from database
        } */
            // return
    }
    
    func DeletePostId(thePost: Post, theUser: WriteableUser) {
        self.currentPost = thePost
        self.currentUser = theUser
        let serialQ = DispatchQueue(label: "com.queue.serial")
        serialQ.sync {
            
            self.currentUser?.deleteCreatedPost(postId: self.currentPost!.postId)
            let dataToWrite2 = try! FirestoreEncoder().encode(self.currentUser)
            self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite2)
            
             //delete image from storage
                   let ref = Storage.storage().reference()
                   let imageRef = ref.child("media/" + (self.currentUser?.email)! + "/" + (self.currentPost?.title)! + "/" + "pic.jpeg")
                   //let ref = Storage.storage().reference(forURL: "media/" + (self.currentUser?.email)! + "/" +  (self.currentPost?.title)! + "/" + "pic.jpeg" )
                   imageRef.delete { error in
                       if let error = error {
                           print("error deleting from storage")
                       } else {
                           print("sucess deleting from storage")
                       }
                   }
            Topic.getTopic(topicTitle: self.currentPost!.topic, completion: self.getTheTopic2)
        }
        
        
        
    }
    
    
    
    
}
