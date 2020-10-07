//
//  Topic.swift
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


struct Topic: Codable {
    var id: String
    var title: String
    var posts: [String]
    var followers: [String]
    
    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
        self.followers = []
        self.posts = []
    }
    
    mutating func addPost (post: Post) {
        // update topic in firebase
        self.posts.append(post.postId)
    }

    mutating func removePost (postId: String) {
        // call firebase delete
        let index: Int = self.posts.firstIndex(of: postId)!
        self.posts.remove(at: index)
    }
    
    static func getTopic(topicTitle: String, completion: @escaping((Topic) -> ())) {
        let db = Firestore.firestore()
        let ref = db.collection("topics").document(topicTitle)
        ref.getDocument { document, error in
            if let document = document {
                if document.data() == nil {
                    print("Topic does not exist")
                    return
                }
                let model = try! FirestoreDecoder().decode(Topic.self, from: document.data()!)
                print("Model: \(model)")
                // call function to add topic to array
                completion(model)
            } else {
                print("Document does not exist")
            }
        }
    }
            
    static func deleteTopic(topicName: String) {
        let db = Firestore.firestore()
        db.collection("topics").document(topicName).delete()
    }
    
    func getPosts(completion: @escaping((Post) -> ())) {
        let db = Firestore.firestore()
        let postsref = db.collection("posts")
        
        for postId in self.posts {
            let ref = postsref.document(postId)
            ref.getDocument { document, error in
                if let document = document {
                    if document.data() == nil {
                        print("Topic does not exist")
                        return
                    }
                    let model = try! FirestoreDecoder().decode(Post.self, from: document.data()!)
                    print("Model: \(model)")
                    // call function to add topic to array
                    completion(model)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}
