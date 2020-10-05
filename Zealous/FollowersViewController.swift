//
//  FollowersViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/4/20.
//


import UIKit

class FollowersViewController: UIViewController {
    
    @IBOutlet weak var followersTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var followers: [WriteableUser] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followersTableView.delegate = self
        followersTableView.dataSource = self
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
        print(currentUser?.followers ?? "")
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
        followers.append(user)
        followersTableView.reloadData()

    }
}


