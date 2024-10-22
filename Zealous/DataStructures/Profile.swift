//
//  Profile.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit

struct Profile {
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var bio: String
    var interests: [String]
    var picture: UIImage?
    var dateOfBirth: Date
    
    init(firstName: String, lastName: String, username: String, email: String){
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.bio = ""
        self.interests = []
        self.picture = nil
        self.dateOfBirth = Date.distantPast
    }
    
    init(firstName: String, lastName: String, username: String, email: String, dob: Date, bio: String, interests: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.bio = bio
        self.interests = []
        self.picture = nil
        self.dateOfBirth = dob;
    }
    init(firstName: String, lastName: String, username: String, email: String, bio: String, interests: [String], dob: Date, picture: UIImage) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.bio = bio
        self.interests = interests
        self.picture = picture
        self.dateOfBirth = dob
    }
    
}
