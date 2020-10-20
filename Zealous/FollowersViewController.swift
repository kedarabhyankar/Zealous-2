//
//  FollowersViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/4/20.
//


import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

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
        print("getUser")
        self.currentUser = currentUser
        
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowers(addUser: addUser) // populates the followers array
        afterGettingCurrentUser()
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

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerUsers", for: indexPath) as? FollowersTableViewCell
        let user = followers[indexPath.item]
        cell?.username?.text = user.username
        let ref2 = Storage.storage().reference(withPath: "media/" + user.email + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell?.Profilepic?.image = UIImage(data: data!)
            }
        }
        return cell!
    }
}
