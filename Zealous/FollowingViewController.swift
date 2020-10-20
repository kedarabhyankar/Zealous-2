//
//  FollowingViewController.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/30/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

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
        followingTableView.reloadData()
    }
    func unfollow(emailId: String) {
        currentUser?.unfollow(email: emailId)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        afterGettingCurrentUser()
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedUsers(addUser: addUser) // populates the following array
    }
    
    func afterGettingCurrentUser() {
        print(currentUser?.followedUsers ?? "")
        currentUser?.getFollowedTopics(addTopic: printTopic)
    }
    
    func printTopic(topic: Topic) {
        print("MY INTERESTS")
        print(topic)
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
        cell?.cellDelegate = self
        let user = following[indexPath.item]
        cell?.Name?.text = user.username
        let ref2 = Storage.storage().reference(withPath: "media/" + user.email + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell?.ProfilePic?.image = UIImage(data: data!)
            }
        }
        
        return cell!
    }
    
}
extension FollowingViewController: CustomCellDelegate {
    func customcell(cell: FollowingViewCell, didTappedThe button: UIButton?, emailId:String) {
        currentUser?.unfollow(email: emailId)
        self.performSegue(withIdentifier: "self", sender: self)
    }
}

