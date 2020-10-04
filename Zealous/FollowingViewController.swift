//
//  FollowingViewController.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/30/20.
//

import UIKit

class FollowingViewController: UIViewController {
    
    @IBOutlet weak var followingTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var following: [WriteableUser] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followingTableView.delegate = self
        followingTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        afterGettingCurrentUser()
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedUsers(addUser: addUser) // populates the following array
        
    }
    
    func afterGettingCurrentUser() {
//        currentUser?.follow(email: "ramesh32@purdue.edu")
        print(currentUser?.followedUsers ?? "")
        let post = Post(topic: "money", title: "test post", caption: "another post", creatorId: currentUser!.email)
        currentUser?.createPost(post: post)
        print(currentUser?.followedUsers ?? "")
    }
    
    func printUserPosts(postArray: [Post]) {
        for post in postArray {
            print(post)
        }
    }
    
    func addPost(likedPost: Post) {
        likedPosts.append(likedPost)
    }
    func addUser(user: WriteableUser) {
        following.append(user)
        followingTableView.reloadData()

    }
}

extension FollowingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingUsers", for: indexPath) as? FollowingViewCell
        let user = following[indexPath.item]
        cell?.Name?.text = user.username
        return cell!
    }
}
