//
//  Topic.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit

struct Topic {
    var topicId: String
    var topicName: String
    var posts: [Post]
    var followers: [User]
    var numFollowers: Int
    
    
    
    init(title: String) {
        self.topicId = UUID().uuidString
        self.topicName = title
        self.numFollowers = 0
        self.followers = []
        self.posts = []
    }
    
    func addTopic(topicId: String) {
        
    }
}
