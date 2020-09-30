//
//  User.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

//struct User: Codable {
//    var id: String = UUID().uuidString
//    var bio: String
//    var dob: String
//    var email: String
//    var firstName: String
//    var lastName: String
//    var username: String
//    var pictureURL: String
//    var createdPosts: [String]
//    var likedPosts: [String]
//    var followedUsers: [String]
//    var followedTopics: [String]
//    var followers: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case bio
//        case dob
//        case email
//        case firstName
//        case lastName
//        case username
//        case pictureURL
//        case createdPosts
//        case likedPosts
//        case followedUsers
//        case followedTopics = "interests"
//        case followers
//    }
//}

extension WriteableUser {
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
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    print("Model: \(model)")
                    likedPosts.append(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
        return likedPosts
    }
    
    static func getCurrentUser() -> WriteableUser? {
        var currUser: WriteableUser? = nil
        let auth = Auth.auth()
        let user = auth.currentUser
        guard let email = user?.email else {
            // error
            print("user email is nil")
            fatalError()
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        userRef.getDocument { document, error in
            if let document = document {
                let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(model)")
                currUser = model
            } else {
                print("Document does not exist")
            }
        }
        return currUser
    }
    
    func follow (email: String) {
        // increase follower count of the user
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        let currentUser = db.collection("users").document(self.email)
        
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
            followedUsers.append(email)
            followers.append(self.email)
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
    
//    func createPost (post: Post) {
//        let db = Firestore.firestore()
//
//        if post.imgURL == "" {
//            db.collection("posts")
//                .document(post.postId)
//                .setData(
//                    ["caption":post.caption,
//                     "comments":post.comments,
//                     "creatorID":self.email,
//                     "imgURL":"",
//                     "postId":post.postId,
//                     "title":post.title,
//                     "topic":post.topic]
//            )
//        }
//        else {
//            let img = UIImage(named: post.imgURL ?? "")!.jpegData(compressionQuality: 1.0)
//
//            guard let imgData = img else {
//                print("img was nil")
//                return
//            }
//
//            let storageRef = Storage.storage().reference()
//            let imagesRef = storageRef.child("posts")
//            let fileName = UUID().uuidString
//            let postRef = imagesRef.child(fileName)
//
//            postRef.putData(imgData, metadata: nil) { metadata, err in
//                if let err = err {
//                    print(err.localizedDescription)
//                    return
//                }
//
//                postRef.downloadURL(completion: { url, err in
//                    if let err = err {
//                        print(err.localizedDescription)
//                        return
//                    }
//                    guard let url = url else {
//                        print("An error occurred when posting an image 3 ")
//                        return
//                    }
//
//                    db.collection("post")
//                        .document(post.postId)
//                        .setData(
//                            ["caption": post.caption,
//                             "postId": post.postId,
//                             "img": url.absoluteString,
//                             "likes": 0,
//                             "comments":post.comments,
//                             "creatorID":self.email,
//                             "title":post.title,
//                             "topic":post.topic]
//                    )
//                })
//            }
//
//            // add the post to the user's createdPosts
//            let currentUser = db.collection("users").document(Auth.auth().currentUser!.email!)
//
//            db.runTransaction({ (transaction, errorPointer) -> Any? in
//                let currentUserDocument: DocumentSnapshot
//                do {
//                    try currentUserDocument = transaction.getDocument(currentUser)
//                } catch let fetchError as NSError {
//                    errorPointer?.pointee = fetchError
//                    return nil
//                }
//
//                guard var posts = currentUserDocument.data()?["createdPosts"] as? [String]                            else {
//                    let error = NSError(
//                        domain: "AppErrorDomain",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(currentUserDocument)"
//                        ]
//                    )
//                    errorPointer?.pointee = error
//                    return nil
//                }
//
//                // update follower and following count
//                posts.append(post.postId)
//                transaction.updateData(["createdPosts": posts], forDocument: currentUser)
//                return nil
//            }) { (object, error) in
//                if let error = error {
//                    print("Transaction failed: \(error)")
//                } else {
//                    print("Transaction successfully committed!")
//                }
//            }
//        }
//    }
    
    func deletePost (post: Post) {
        
    }
    
    func message (msg: String) {
        
    }
    
    func block (user: User) {
        
    }
    
//    func updateProfilePic (img: UIImage) {
//        let db = Firestore.firestore()
//
//        guard let imgData = img.jpegData(compressionQuality: 1.0)
//            else {
//                return
//        }
//
//        let storageRef = Storage.storage().reference()
//        let imagesRef = storageRef.child("profilePics")
//        let fileName = UUID().uuidString
//        let postRef = imagesRef.child(fileName)
//
//        postRef.putData(imgData, metadata: nil) { metadata, err in
//            if let err = err {
//                print(err.localizedDescription)
//                return
//            }
//
//            postRef.downloadURL(completion: { url, err in
//                if let err = err {
//                    print(err.localizedDescription)
//                    return
//                }
//                guard let url = url else {
//                    print("An error occurred when posting an image 3 ")
//                    return
//                }
//
//                db.collection("users")
//                    .document(self.email)
//                    .setData(
//                        ["profilePic": url.absoluteString]
//                )
//            })
//        }
//    }
    
//    func updateBio (bio: String) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(self.email)
//        userRef.updateData(["bio": bio]) { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//            }
//        }
//    }
}

extension Timestamp: TimestampType {}
