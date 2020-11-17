//
//  DeleteUser.swift
//  Zealous
//
//  Created by Hannah Shiple on 11/11/20.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase

extension WriteableUser {
    
    
     static func deleteUser(theUser: WriteableUser) {
        var followedTopics: [Topic] = []
        var createdPosts: [Post] = []
        var theUser: WriteableUser = theUser
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.async {
        WriteableUser.getCreatedPosts(email: theUser.email, completion: { (postArray) in
            if postArray == nil {
                print("error getting created posts array")
            } else {
                createdPosts = postArray
            }
        })
            group.leave()
        }
        group.notify(queue: .main) {
                print("createdPosts done")
            }
        
        //1. delete the user's created posts
        group.enter()
        DispatchQueue.main.async {
        for aPost in createdPosts {
            //delete from topic's post array and delete topic if post array count is zero
            Topic.getTopic(topicTitle: aPost.topic, completion: { (theTopic) in
                if theTopic == nil {
                    print("error getting the topic")
                } else {
                    var topic: Topic = theTopic
                    for post in createdPosts {
                        if (theTopic.posts.contains(post.postId)) {
                            topic.removePost(postId: post.postId)
                            if (theTopic.posts.count == 0) {
                                Topic.deleteTopic(topicName: theTopic.title)
                            }
                        }
                    }
                    if (theTopic.posts.count == 0) {
                        Topic.deleteTopic(topicName: theTopic.title)
                    }
                }
            })
            Post.deleteStoragePost(thePost: aPost, theUser: theUser)
            Post.deletePost(postId: aPost.postId)
        }
            group.leave()
        }
        group.notify(queue: .main) {
                print("delete createdPosts done")
            }
        
        //2. make the user's unfollow the user
        group.enter()
        DispatchQueue.main.async {
        theUser.getFollowers(addUser: { follower in
            if (follower == nil) {
                print("error getting the follower user")
            } else {
            var aFollower: WriteableUser = follower
            aFollower.unfollow(email: theUser.email)
            }
        })
            group.leave()
        }
        group.notify(queue: .main) {
                print("unfollow done")
            }
        
        //3. unfollow all the followed users
        group.enter()
        DispatchQueue.main.async {
        theUser.getFollowedUsers(addUser: { followed in
            if (followed == nil) {
                print("error getting followed user")
            } else {
                theUser.unfollow(email: followed.email)
            }
        })
            group.leave()
        }
        group.notify(queue: .main) {
                print("followed done")
            }
        
        //4. unfollow all the followed topics
        group.enter()
        DispatchQueue.main.async {
        theUser.getFollowedTopics(addTopic: { topic in
            theUser.unfollowTopic(title: topic.title)
        })
            group.leave()
        }
        group.notify(queue: .main) {
                print("unfollow topic done")
            }
        
        //5. delete everything from storage
        group.enter()
        DispatchQueue.main.async {
        let ref = Storage.storage().reference()
        let imageRef = ref.child("media/" + (theUser.email) + "/profile.jpeg")
        imageRef.delete { error in
            if let error = error {
                print("Error deleting user from storage \(error)")
            }
        }
            group.leave()
        }
        group.notify(queue: .main) {
                print("delete storage done")
            }
        
        
        //6. delete user from firestore
        group.enter()
        DispatchQueue.main.async  {
        var db: Firestore!
            let firestoreSettings = FirestoreSettings()
            Firestore.firestore().settings = firestoreSettings
            db = Firestore.firestore()
            db.collection("users").document(theUser.email).delete(completion: {
                error in
                if (error != nil) {
                        print("error deleting user from firestore \(String(describing: error))")
                } else {
                    print("deleted user from firestore")
                }
                                                                
            })
           
            group.leave()
        }
        group.notify(queue: .main) {
            print("delete firestore done")
            }
        //7. delete user form auth
       // FirebaseAuth.getuid()
        
        //var thisUser: User = User.sign
       // FirebaseAuth.Auth.auth().updateCurrentUser(, completion: )
        
        var db2: Firestore!
        let firestoreSettings2 = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings2
        db2 = Firestore.firestore()
        db2.collection("users").document(theUser.email).getDocument() { (doc, error) in
            if (doc != nil) {
                db2.collection("users").document(theUser.email).delete()
                print("deleted user again")
            }
        }
        
        
        
    }
    
    
}
