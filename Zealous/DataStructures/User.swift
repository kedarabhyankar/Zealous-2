//
//  User.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class User {
    var profile: Profile
    var id: String
    var createdPosts: [Post]
    var likedPosts: [Post] // stores postId's
    var followedUsers: [User] // stores creatorId's
    var followedTopics: [Topic] // stores topicId's
    var followers: [User] // stores creatorId's
    var numFollowers: Int {
        return followedUsers.count
    }
    var numFollowing: Int {
        return followers.count
    }
    
    func follow (user: User) {
        
        // increase follower count of the user
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        let currentUser = db.collection("users").document(self.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            let currentUserDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(userRef)
                try currentUserDocument = transaction.getDocument(currentUser)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            //            guard let oldFollowers = sfDocument.data()?["numFollowers"] as? Int,
            //                let oldFollowing = currentUserDocument.data()?["numFollowing"] as? Int,
            guard var followedUsers = currentUserDocument.data()?["followedUsers"] as? [String],
                var followers = sfDocument.data()?["followers"] as? [String]
                else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
            }
            
            //update followedUsers
            followedUsers.append(user.id)
            followers.append(self.id)
            // update follower and following count
            transaction.updateData(["numFollowers": followers.count], forDocument: userRef)
            transaction.updateData(["followers": followers], forDocument: userRef)
            
            transaction.updateData(["numFollowing": followedUsers.count], forDocument: currentUser)
            transaction.updateData(["followedUsers": followedUsers], forDocument: currentUser)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    func createPost (post: Post) {
        let db = Firestore.firestore()
        
        if post.img == nil {
            db.collection("posts")
                .document(post.postId)
                .setData(
                    ["caption":post.caption,
                     "comments":post.comments,
                     "creatorID":self.id,
                     "img":"",
                     "postId":post.postId,
                     "title":post.title,
                     "topic":post.topic]
            )
        }
        else {
            let img = post.img?.jpegData(compressionQuality: 1.0)
            
            guard let imgData = img else {
                print("img was nil")
                return
            }
            
            let storageRef = Storage.storage().reference()
            let imagesRef = storageRef.child("posts")
            let fileName = UUID().uuidString
            let postRef = imagesRef.child(fileName)
            
            postRef.putData(imgData, metadata: nil) { metadata, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                postRef.downloadURL(completion: { url, err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    guard let url = url else {
                        print("An error occurred when posting an image 3 ")
                        return
                    }
                    
                    db.collection("post")
                        .document(post.postId)
                        .setData(
                            ["caption": post.caption,
                             "postId": post.postId,
                             "img": url.absoluteString,
                             "likes": 0,
                             "comments":post.comments,
                             "creatorID":self.id,
                             "title":post.title,
                             "topic":post.topic]
                    )
                })
            }
            
            // add the post to the user's createdPosts
            let currentUser = db.collection("users").document(self.id)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let currentUserDocument: DocumentSnapshot
                do {
                    try currentUserDocument = transaction.getDocument(currentUser)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard var posts = currentUserDocument.data()?["createdPosts"] as? [String]                            else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(currentUserDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                // update follower and following count
                posts.append(post.postId)
                transaction.updateData(["createdPosts": posts], forDocument: currentUser)
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }
        }
    }
    
    func deletePost (post: Post) {
        
    }
    
    func message (msg: String) {
        
    }
    
    func block (user: User) {
        
    }
    
    func updateProfilePic (img: UIImage) {
        let db = Firestore.firestore()
        
        guard let imgData = img.jpegData(compressionQuality: 1.0)
            else {
                return
        }
        
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child("profilePics")
        let fileName = UUID().uuidString
        let postRef = imagesRef.child(fileName)
        
        postRef.putData(imgData, metadata: nil) { metadata, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            postRef.downloadURL(completion: { url, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else {
                    print("An error occurred when posting an image 3 ")
                    return
                }
                
                db.collection("users")
                    .document(self.id)
                    .setData(
                        ["profilePic": url.absoluteString]
                )
            })
        }
    }
    
    func updateBio (bio: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.id)
        userRef.updateData(["bio": bio]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    init(profile: Profile) {
        self.id = UUID().uuidString
        self.profile = profile
        self.likedPosts = []
        self.createdPosts = []
        self.followedUsers = []
        self.followedTopics = []
        self.followers = []
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(id)
            .setData([
                "username": profile.username,
                "bio": profile.bio,
                "creatorId": self.id,
                "email":profile.email,
                "profilePic":"",
                "numFollowers":0,
                "numFollowing":0,
                "likedPosts":[],
                "followedUsers":[],
                "followedTopics":[],
                "createdPosts":[]
                ]
            ){ err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
        }
    }
}
