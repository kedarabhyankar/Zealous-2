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
import FirebaseStorage

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
        let db = Firestore.firestore()
        let serialQ = DispatchQueue(label: "com.queue.serial")
        print("created posts: \(createdPosts)")
        print("followers: \(followers)")
        print("following: \(following)")
        print("followed topics: \(followedTopics)")
        
        serialQ.sync {
        for aPost in createdPosts {
                   //delete from topic's post array and delete topic if post array count is zero
            Topic.getTopic(topicTitle: aPost.topic, completion: self.getTopic)
            Post.deleteStoragePost(thePost: aPost, theUser: self.currentUser!)
            Post.deletePost(postId: aPost.postId)
            
        }
        let data = try! FirestoreEncoder().encode(currentUser)
        db.collection("users").document(currentUser!.email).setData(data)
        
        }
        
        serialQ.sync {
        let ref = Storage.storage().reference()
        let imageRef = ref.child("media/" + (self.currentUser?.email)! + "/profile.jpeg")
        imageRef.delete { error in
            if let error = error {
                print("error deleting user from storage \(error)")
            } else {
                print("sucess deleting user from stroage")
            }
        }
        }
        
        serialQ.sync {
        db.collection("users").document((self.currentUser?.email)!).delete() {
            error in
            if (error != nil) {
                print("error deleting user from firestore \(String(describing: error))")
            } else {
                print("success deleting user from firestore")
            }
        }
        }
    }
    
    
    func getTopic(thetopic: Topic) {
        DispatchQueue.main.async {
        self.theTopic = thetopic
        for aPost in self.createdPosts {
            if (self.theTopic!.posts.contains(aPost.postId)) {
                self.theTopic!.removePost(postId: aPost.postId)
                if (self.theTopic!.posts.count == 0) {
                    Topic.deleteTopic(topicName: self.theTopic!.title)
                }                //let index: Int? = self.theTopic!.posts.firstIndex(of: aPost.postId)
                //self.theTopic!.posts.remove(at: index!)
            }
        }
        //if the topic's post array is empty delete the topic
        print("topic post array count: \(self.theTopic!.posts.count)")
        if (self.theTopic!.posts.count == 0) {
            Topic.deleteTopic(topicName: self.theTopic!.title)
        }
        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
