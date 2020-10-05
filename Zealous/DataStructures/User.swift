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

extension WriteableUser {
    
    
    mutating func addCreatedPost(post: Post) {
        self.createdPosts.append(post.postId)
    }
    func getFollowedTopics() {
        let db = Firestore.firestore()
        for id in self.interests {
            // get the post and convert to Post object
            let ref = db.collection("users").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    print("Model: \(model)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getFollowedUsers(addUser: @escaping((WriteableUser) -> ())) {
        let db = Firestore.firestore()
        for id in self.followedUsers {
            // get the post and convert to Post object
            let ref = db.collection("users").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    print("Model: \(model)")
                    addUser(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getFollowers(addUser: @escaping((WriteableUser) -> ())){
        let db = Firestore.firestore()
        for id in self.followers {
            // get the post and convert to Post object
            let ref = db.collection("users").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                    print("Model: \(model)")
                    addUser(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    static func getCreatedPosts(email: String, completion: @escaping(([Post]) -> ())) {
        let db = Firestore.firestore()
        db.collection("posts").whereField("creatorId", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var createdPosts: [Post] = []
                    for document in querySnapshot!.documents {
                        let model = try! FirestoreDecoder().decode(Post.self, from: document.data())
                        createdPosts.append(model)
                        print("\(document.documentID) => \(document.data())")
                    }
                    completion(createdPosts)
                }
        }
    }
    
    func getLikedPosts(addPost: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        for id in self.likedPosts {
            // get the post and convert to Post object
            let ref = db.collection("posts").document(id)
            ref.getDocument { document, error in
                if let document = document {
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    print("Model: \(model)")
                    addPost(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    static func getCurrentUser(completion: @escaping((WriteableUser) -> ())) {
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
                completion(model)
            } else {
                print("Document does not exist")
            }
        }
    }
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    mutating func follow (email: String) {
        // Error Banners
        let followSelf = Banner(title: "You can't follow yourself.", subtitle: "Choose a different user to follow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        followSelf.dismissesOnTap = true
        
        let alreadyFollow = Banner(title: "You are already following this user.", subtitle: "Choose a different user to follow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyFollow.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
                   print("you can't follow yourself")
            self.showAndFocus(banner: followSelf)
                   return
        }
        
        if self.followedUsers.contains(email) {
            print("you already follow this user")
            self.showAndFocus(banner: alreadyFollow)
            return
        }
        self.followedUsers.append(email)
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // get the user that was followed and update the followers array, then write the user
        // to the db
        let thisEmail = self.email
        
        userRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(model)")
                model.followers.append(thisEmail)
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    mutating func unfollow (email: String) {
        // Error Banners
        let unfollowSelf = Banner(title: "You can't unfollow yourself.", subtitle: "Choose a different user to unfollow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unfollowSelf.dismissesOnTap = true
        
        let unfollowUser = Banner(title: "You can't unfollow this user.", subtitle: "Choose a different user that you already follow to unfollow.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        unfollowUser.dismissesOnTap = true
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
            self.showAndFocus(banner: unfollowSelf)
            print("you can't unfollow yourself")
            return
        }
        if !self.followedUsers.contains(email) {
            self.showAndFocus(banner: unfollowUser)
            print("you are not following this user")
            return
        }
        // delete user from following array
        for i in 0..<self.followedUsers.count {
            if self.followedUsers[i] == email {
                self.followedUsers.remove(at: i)
                break
            }
        }
        let dataToWrite = try! FirestoreEncoder().encode(self)
        db.collection("users").document(self.email).setData(dataToWrite) { error in
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
        
        // update the followers array, then write the user
        // to the db
        let thisEmail = self.email
        
        userRef.getDocument { document, error in
            if let document = document {
                var model = try! FirestoreDecoder().decode(WriteableUser.self, from: document.data()!)
                print("Model: \(model)")
                for i in 0..<model.followers.count {
                    if model.followers[i] == thisEmail {
                        model.followers.remove(at: i)
                        break
                    }
                }
                let dataToWrite2 = try! FirestoreEncoder().encode(model)
                db.collection("users").document(email).setData(dataToWrite2) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        return
                    } else {
                        print("successfully wrote document to firestore with document id )")
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func createPost (post: Post) {
        let db = Firestore.firestore()
        let dataToWrite2 = try! FirestoreEncoder().encode(post)
        db.collection("posts").document(post.postId).setData(dataToWrite2) { error in
            
            if(error != nil){
                print("error happened when writing to firestore!")
                print("described error as \(error!.localizedDescription)")
                return
            } else {
                print("successfully wrote document to firestore with document id )")
            }
        }
    }
    
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
