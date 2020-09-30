
//
//  Post.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit
import Firebase
import FirebaseFirestore

struct Post {
    var postId: String
    var topic: String
    var creatorId: String
    var title: String
    var caption: String
    var img: UIImage?
    var comments: [String]
    var likes: Int
    var timeStamp: Timestamp
    
    init(topic: String, title: String, caption: String) {
        self.postId = UUID().uuidString
        self.title = title
        self.caption = caption
        self.comments = []
        self.topic = topic
        self.img = nil
        self.creatorId = ""
        self.likes = 0
        self.timeStamp = Timestamp.init()
    }
    
    init(topic: String, title: String, caption: String, creatorId: String) {
        self.init(topic: topic, title: title, caption: caption)
        self.creatorId = creatorId
    }
    
    init(topic: String, title: String, caption: String, creatorId: String, img: UIImage) {
        self.init(topic: topic, title: title, caption: caption, creatorId: creatorId)
        self.img = img
    }
    
    func addPost (postId: String) {
        // update topic in firebase
        
    }

    func removePost (postId: String) {
        // call firebase delete
    }
    
}
