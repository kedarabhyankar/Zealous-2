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
    
    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
        self.numFollowers = 0
        self.followers = []
        self.posts = []
    }
    
    mutating func addPost (post: Post) {
        // update topic in firebase
        self.posts.append(post.postId)
    }

    func removePost (postId: String) {
        // call firebase delete
    }
    
    
    /* static func getTopic(topicName: String , completion: @escaping((Topic) -> ())) {
        let db = Firestore.firestore()
        let topicRef = db.collection("topics")
        
        topicRef.whereField("title", isEqualTo: topicName).getDocuments() { querySnapshot, error in
            if error != nil {
                print("error getting document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let model = try! FirestoreDecoder().decode(Topic.self, from: document.data())
                    print("Model: \(model)")
                    completion(model)
                    return 
                }
                
            }
        }
    }*/
    
    static func getTopic(topicName: String, completion: @escaping((Topic) -> ())) {
        let db = Firestore.firestore()
        let topicRef = db.collection("topics")
        //var model: Topic?
        
        topicRef.whereField("title", isEqualTo: topicName).getDocuments() { querySnapshot, error in
            if error != nil {
                print("error getting document: \(String(describing: error))")
                //return nil
            } else {
                var count = 0
                for document in querySnapshot!.documents {
                   // if (count == 1) {
                        let model = try! FirestoreDecoder().decode(Topic.self, from: document.data())
                        print("Model:   \(count), \(String(describing: model))")
                        completion(model)
                  //  }
                    count += 1
                    //completion(model)
                    //return model
                }
                
            }
        }
    }
    
}
