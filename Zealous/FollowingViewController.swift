//
//  FollowingViewController.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/30/20.
//

import UIKit

class FollowingViewController: UIViewController {
    
    var currentUser: WriteableUser? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        WriteableUser.getCurrentUser(completion: getUser)

    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        afterGettingCurrentUser()
    }
    
    func afterGettingCurrentUser() {
        currentUser?.follow(email: "ramesh32@purdue.edu")
        print(currentUser?.followedUsers ?? "")
        let post = Post(topic: "money", title: "test post", caption: "another post", creatorId: currentUser!.email)
        currentUser?.createPost(post: post)
        currentUser?.unfollow(email: "ramesh32@purdue.edu")
        print(currentUser?.followedUsers ?? "")
    }

}
