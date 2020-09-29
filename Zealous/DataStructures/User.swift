//
//  User.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestoreSwift


struct User: Codable {
    var id: String = UUID().uuidString
    var bio: String
    var dob: String
    @DocumentID var email: String?
    var firstName: String
    var lastName: String
    var username: String
    var pictureURL: String
    var createdPosts: [String]
    var likedPosts: [String]
    var followedUsers: [String]
    var followedTopics: [String]
    var followers: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case bio
        case dob
        case email
        case firstName
        case lastName
        case username
        case pictureURL
        case createdPosts
        case likedPosts
        case followedUsers
        case followedTopics = "interests"
        case followers
    }
}
