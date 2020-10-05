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
    var timestamp: String
    
    init(topic: String, title: String, caption: String) {
        self.postId = UUID().uuidString
        self.title = title
        self.caption = caption
        self.comments = []
        self.topic = topic
        self.imgURL = nil
        self.creatorId = ""
        self.likes = 0
        let today = Date()
        //let formatter1 = DateFormatter()
        //formatter1.dateStyle = .short
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        //self.timestamp = formatter1.string(from: today)
        self.timestamp = dateFormatterGet.string(from: today)
    }
    
    init(topic: String, title: String, caption: String, creatorId: String) {
        self.init(topic: topic, title: title, caption: caption)
        self.creatorId = creatorId
    }
    
    init(topic: String, title: String, caption: String, creatorId: String, img: String?) {
        self.init(topic: topic, title: title, caption: caption, creatorId: creatorId)
        self.imgURL = img
    }
}
