//
//  Profile.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/16/20.
//
import Foundation
import UIKit

struct Profile {
    var username: String
    var email: String
    var bio: String
    var picture: UIImage?
    var dateOfBirth: Date
    
    init(username: String, email: String, dob: Date, bio: String) {
        self.username = username
        self.email = email
        self.bio = bio
        self.picture = nil
        self.dateOfBirth = dob;
    }
    init(username: String, email: String, bio: String, dob: Date, picture: UIImage) {
        self.username = username
        self.email = email
        self.bio = bio
        self.picture = picture
        self.dateOfBirth = dob
    }
}
