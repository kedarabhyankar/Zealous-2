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
    
    mutating func follow (email: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
                   print("you can't follow yourself")
                   return
        }
        
        if self.followedUsers.contains(email) {
            print("you already follow this user")
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
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(email)
        
        // append user to followedUsers then write data to firestore
        if (self.email == email) {
                          print("you can't unfollow yourself")
                          return
               }
        if !self.followedUsers.contains(email) {
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
