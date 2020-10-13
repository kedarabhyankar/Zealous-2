//
//  TopicsViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/6/20.
//

import UIKit

class TopicsViewController: UIViewController {
 
    @IBOutlet weak var topicsTableView: UITableView!
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var topics: [Topic] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        print("getUser")
        self.currentUser = currentUser
        
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedTopics(addTopic: addTopic) // populates the topics array
        afterGettingCurrentUser()
    }
    
    func afterGettingCurrentUser() {
       // print(currentUser?.interests ?? "")
       // topicsTableView.reloadData()
       // print(currentUser?.interests ?? "")
        topicsTableView.reloadData()
    }
    
    func printUserPosts(postArray: [Post]) {
        for post in postArray {
            print(post)
        }
    }
    
    func addPost(likedPost: Post) {
        likedPosts.append(likedPost)
    }
    func addTopic(topic: Topic) {
        topics.append(topic)
        topicsTableView.reloadData()
    }
}

extension TopicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Topics", for: indexPath) as? TopicsViewCell
        let top = topics[indexPath.item]
        cell?.name?.text = top.title
        return cell!
    }
}
