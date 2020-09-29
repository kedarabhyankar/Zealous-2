//
//  Post.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit

struct Post: Codable {
    var postId: String
    var topic: String
    var creatorId: String
    var title: String
    var caption: String
    var imgURL: String
    var comments: [String]
    var likes: Int
    
    private init(topic: String, title: String, caption: String) { // for creating post
        self.postId = UUID().uuidString
        self.title = title
        self.caption = caption
        self.comments = []
        self.topic = topic
        self.imgURL = ""
        self.creatorId = ""
        self.likes = 0
    }
    
    init(topic: String, title: String, caption: String, creatorId: String) {
        self.init(topic: topic, title: title, caption: caption)
        self.creatorId = creatorId
    }
    init(topic: String, title: String, caption: String, creatorId: String, img: String) {
        self.init(topic: topic, title: title, caption: caption, creatorId: creatorId)
        self.imgURL = img
    }
    init(id: String, topic: String, title: String, caption: String, creatorId: String, comments: [String], likes: Int) {
        self.postId = id
        self.topic = topic
        self.title = title
        self.caption = caption
        self.comments = comments
        self.creatorId = creatorId
        self.imgURL = ""
        self.likes = likes
    }
}
