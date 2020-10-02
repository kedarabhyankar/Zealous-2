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
    var numFollowers: Int
    
    mutating func addPost (post: Post) {
        // update topic in firebase
        self.posts.append(post.postId)
    }

    func removePost (postId: String) {
        // call firebase delete
    }
    
    
    static func getTopic(topicName: String , completion: @escaping((Topic) -> ())) {
        let db = Firestore.firestore()
        let topicRef = db.collection("topics")
        
        topicRef.whereField("title", isEqualTo:topicName).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error getting document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Topic.self, from: document.data())
                    completion(model)
                }
                
            }
        }
    }
    
    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
        self.numFollowers = 0
        self.followers = []
        self.posts = []
    }
}
