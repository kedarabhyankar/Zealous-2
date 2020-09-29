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
    var createdPosts: [Post] {
        return getCreatedPosts(email: profile.email)
    }
    var likedPosts: [String] // stores postId's
    var followedUsers: [String] // stores creatorId's
    var followedTopics: [String] // stores topicId's
    var followers: [String] // stores creatorId's
    var numFollowers: Int {
        return followedUsers.count
    }
    
    init(username: String, bio: String, creatorId: String, email: String, createdPosts: [String], likedPosts: [String], followedUsers: [String], followedTopics: [String], followers: [String]) {
        self.profile = Profile(username: username, email: email, bio: bio)
        self.likedPosts = likedPosts
        self.followedUsers = followedUsers
        self.followedTopics = followedTopics
        self.followers = followers
    }
    
    func getFollowedTopics(topics: [String]) -> [Topic] {
        return []
    }
    
    func getFollowedUsers(userIds: [String]) -> [User] {
        return []
    }
    
    func getFollowers(userIds: [String]) -> [User] {
        return []
    }
    
    func getCreatedPosts(email: String) -> [Post] {
        let db = Firestore.firestore()
        db.collection("posts").whereField("creatorId", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
        return []
    }
    
    func getLikedPosts(postIds: [String]) -> [Post] {
        var likedPosts: [Post] = []
        let db = Firestore.firestore()
        for id in postIds {
            // get the post and convert to Post object
            let ref = db.collection("posts").document(id)
            ref.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    // populate user object with data and return
                    let postdata = document.data()!
                    let topic = postdata["topic"] as! String
                    let creatorId = postdata["creatorId"] as! String
                    let title = postdata["title"] as! String
                    let caption = postdata["caption"] as! String
                    let comments = postdata["comments"] as! [String]
                    let likes = postdata["likes"] as! Int
                    
                    likedPosts.append(Post(id: id, topic: topic, title: title, caption: caption, creatorId: creatorId, comments: comments, likes: likes))
                    
                    print("Document data: \(dataDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
        return likedPosts
    }
    
    func createUser(profile: Profile) {
        let db = Firestore.firestore()
        // store the user with document id = email
        db.collection("users")
            .document(profile.email)
            .setData([
                "username": profile.username,
                "bio": profile.bio,
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
    
    func currentUser() -> User? {
        var currUser: User? = nil
        guard let auth = Auth.auth().currentUser else {
            // error
            return nil
        }
        guard let email = auth.email else {
            // error
            return nil
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                // populate user object with data and return
                let userdata = document.data()!
                let username = userdata["username"] as! String
                let bio = userdata["bio"] as! String
                let id = userdata["creatorId"] as! String
                let createdPosts = userdata["createdPosts"] as! [String]
                let likedPosts = userdata["likedPosts"] as! [String]
                let followedUsers = userdata["followedUsers"] as! [String]
                let followedTopics = userdata["followedTopics"] as! [String]
                let followers = userdata["followers"] as! [String]
                currUser = User(username: username,
                                bio: bio,
                                creatorId: id,
                                email: id,
                                createdPosts: createdPosts,
                                likedPosts: likedPosts,
                                followedUsers: followedUsers,
                                followedTopics: followedTopics,
                                followers: followers)
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        return currUser
    }
    
    func follow (user: User) {
        // increase follower count of the user
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.profile.email)
        let currentUser = db.collection("users").document(self.profile.email)
        
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
            followedUsers.append(user.profile.email)
            followers.append(self.profile.email)
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
                     "creatorID":self.profile.email,
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
                             "creatorID":self.profile.email,
                             "title":post.title,
                             "topic":post.topic]
                    )
                })
            }
            
            // add the post to the user's createdPosts
            let currentUser = db.collection("users").document(Auth.auth().currentUser!.email!)
            
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
                    .document(self.profile.email)
                    .setData(
                        ["profilePic": url.absoluteString]
                )
            })
        }
    }
    
    func updateBio (bio: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.profile.email)
        userRef.updateData(["bio": bio]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func register() {
        
    }
    
    func signIn(){
        
    }
    
    
}
