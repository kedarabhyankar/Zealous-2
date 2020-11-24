//
//  AdminUsersViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/12/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore
import CodableFirebase

class AdminUsersViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    var db: Firestore!
    var associatedEmail:String? = nil
    var createdPosts: [Post] = []
    var following: [WriteableUser] = []
    var followers: [WriteableUser] = []
    var followedTopics: [Topic] = []
    var theTopic: Topic? = nil
    var currentUser: WriteableUser? = nil
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        var username2: String = username.text!
        WriteableUser.getEmail(username: username2, completion: afterEmail)
    }
    
    func afterEmail(email: String) {
        WriteableUser.getAUser(theEmail: email, completion: getUser)
    }
    
    func getUser(theUser: WriteableUser) {
        currentUser = theUser
        //DispatchQueue.main.async { [self] in
        currentUser?.getFollowerArray(user: currentUser!, completion: followerArray)
       // currentUser?.getFollowedArray(completion: followedArray)
        //currentUser?.getFollowedTopics(addTopic: topicArray)
       
       // }
        //deleteUser()
    }
    
    func getPosts(postArray: [Post]) {
        createdPosts = postArray
        deleteUser()
    }
    
    func followerArray(followerArray: [WriteableUser]) {
        followers = followerArray
        currentUser?.getFollowedArray(user: currentUser!, completion: followedArray)
    }
    
    func followedArray(followedArray: [WriteableUser]) {
        following = followedArray
        WriteableUser.getCreatedPosts(email: currentUser!.email, completion: getPosts)
        //currentUser?.getFollowedTopics(addTopic: topicArray)
    }
    
    func topicArray(topic: Topic) {
        followedTopics.append(topic)
    }
    
    func deleteUser() {
        print("created posts: \(createdPosts)")
        print("followers: \(followers)")
        print("following: \(following)")
        print("followed topics: \(followedTopics)")
        
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
