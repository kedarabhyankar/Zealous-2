//
//  Post.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
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

struct Post: Codable {
    var postId: String
    var topic: String
    var creatorId: String
    var title: String
    var caption: String
    var imgURL: String?
    var comments: [String]
    var likes: Int
    var dislikes: Int
    var timestamp: String
    var madeAnonymously: Bool
    
    init(topic: String, title: String, caption: String) {
        self.postId = UUID().uuidString
        self.title = title
        self.caption = caption
        self.comments = []
        self.topic = topic
        self.imgURL = nil
        self.creatorId = ""
        self.likes = 0
        self.dislikes = 0
        let today = Date()
        //let formatter1 = DateFormatter()
        //formatter1.dateStyle = .short
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        //self.timestamp = formatter1.string(from: today)
        self.timestamp = dateFormatterGet.string(from: today)
        self.madeAnonymously = false;
    }
    
    init(topic: String, title: String, caption: String, creatorId: String, anon: Bool) {
        self.init(topic: topic, title: title, caption: caption)
        self.creatorId = creatorId
        self.madeAnonymously = anon;
    }
    
    init(topic: String, title: String, caption: String, creatorId: String, img: String?, anon: Bool) {
        self.init(topic: topic, title: title, caption: caption, creatorId: creatorId, anon: anon)
        self.imgURL = img
        self.madeAnonymously = anon;
    }
    
    static func getPost(postId: String, completion: @escaping((Post) -> ())) {
        DispatchQueue.main.async {
            let db = Firestore.firestore()
            let topicRef = db.collection("posts")
            //var model: Topic?
            
            topicRef.document(postId).getDocument() { querySnapshot, error in
                if (error != nil) {
                    print("error getting document: \(String(describing: error))")
                    return 
                }
                if (querySnapshot?.data() == nil) {
                    return
                } else {
                    let model = try! FirestoreDecoder().decode(Post.self, from: (querySnapshot?.data())!)
                    //print("Model:  \(String(describing: model))")
                    completion(model)
                    //completion(model)
                    //return model
                    
                }
            }
        }
        
    }
    
    static func deletePost(postId: String) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).delete()
    }
    
    static func deleteStoragePost(thePost: Post, theUser: WriteableUser) {
        let ref = Storage.storage().reference()
        let imageRef = ref.child("media/" + (theUser.email) + "/" + (thePost.title) + "/" + "pic.jpeg")
        //let ref = Storage.storage().reference(forURL: "media/" + (self.currentUser?.email)! + "/" +  (self.currentPost?.title)! + "/" + "pic.jpeg" )
        imageRef.delete { error in
            if let error = error {
                print("error deleting from storage")
            } else {
                print("sucess deleting from storage")
            }
        }
    }
    
    func getComments(postID: String, addComment: @escaping(([String]) -> ())){
        //Get all Comments per Post
        //Refer to liked posts
        let db = Firestore.firestore()
        let ref = db.collection("comments").document(postID)
        ref.getDocument { document, error in
            if let document = document {
                if document.data() != nil {
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    addComment(model.comments)
                }
                else {
                    print("Document does not exist or has been deleted")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
