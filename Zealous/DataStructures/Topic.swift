//
//  Topic.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation

struct Topic {
    var id: String
    var title: String
    var description: String
    var posts: [String]
    var followers: [String]
    var numFollowers: Int
    
    func addPost (postId: String) {
        // update topic in firebase
        
    }

    func removePost (postId: String) {
        // call firebase delete
    }
    
    init(title: String, description: String) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.numFollowers = 0
        self.followers = []
        self.posts = []
    }
}
