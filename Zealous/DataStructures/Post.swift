//
//  Post.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit

struct Post {
    var postId: String
    var topic: String
    var creatorId: String
    var title: String
    var caption: String
    var img: UIImage?
    var comments: [String]
    var likes: Int
    
    init(topic: String, title: String, caption: String) {
        self.postId = UUID().uuidString
        self.title = title
        self.caption = caption
        self.comments = []
        self.topic = topic
        self.img = nil
        self.creatorId = ""
        self.likes = 0
    }
    
    init(topic: String, title: String, caption: String, creatorId: String) {
        self.init(topic: topic, title: title, caption: caption)
        self.creatorId = creatorId
    }
    
    init(topic: String, title: String, caption: String, creatorId: String, img: UIImage) {
        self.init(topic: topic, title: title, caption: caption, creatorId: creatorId)
        self.img = img
    }
}
