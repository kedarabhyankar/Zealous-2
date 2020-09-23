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
    var password: String
    var bio: String
    var picture: UIImageView
    
    init(username: String, email: String, password: String, bio: String) {
        self.username = username
        self.email = email
        self.password = password
        self.bio = bio
        self.picture = UIImageView(image: UIImage(named: "default-profile-picture"))    }
    init(username: String, email: String, password: String, bio: String, picture: UIImageView) {
        self.username = username
        self.email = email
        self.password = password
        self.bio = bio
        self.picture = picture
    }
}
