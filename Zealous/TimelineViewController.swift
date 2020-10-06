//
//  TimelineViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/5/20.
//

import UIKit

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var following: [WriteableUser] = []
    var posts: [Post] = []
     var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
        timelineTableView.rowHeight = 508
        timelineTableView.estimatedRowHeight = 508
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        //afterGettingCurrentUser()
       // WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedUsers(addUser: addUser) // populates the following array
        currentUser.getFollowedTopics(addTopic: addTopic)
        
    }
    func addTimeline(post: [Post]) {
        for postItem in post {
        posts.append(postItem)
            print(postItem)
        }
        timelineTableView.reloadData()
    }
    func addTopic(topic: Topic) {
        topics.append(topic)
    }
    
    func afterGettingCurrentUser() {
//        currentUser?.follow(email: "ramesh32@purdue.edu")
       // print(currentUser?.followedUsers ?? "")
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
        WriteableUser.getCreatedPosts(email: user.email, completion: addTimeline)
        timelineTableView.reloadData()
    }
}


extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedView", for: indexPath) as! FeedViewCell
        let user = posts[indexPath.item]
        cell.username?.text = user.creatorId
        cell.postTitle?.text = user.title
        cell.postCaption?.text = user.caption
        return cell
    }
}

