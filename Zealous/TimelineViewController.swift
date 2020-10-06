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
        posts.sort(by: {$0.timestamp > $1.timestamp})
        timelineTableView.reloadData()
    }
    func addTimeline(postArray: [Post]) {
        for postItem in postArray {
        posts.append(postItem)
            print(postItem)
        }
        timelineTableView.reloadData()
    }
    func addTopic(topic: Topic) {
        topics.append(topic)
        topic.getPosts { (post) in
            for postItem in self.posts {
                if(postItem.postId == post.postId) {
                    return
                }
            }
            self.posts.append(post)
            self.timelineTableView.reloadData()
        }
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
        // Sort the posts by timestamp
        posts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedView", for: indexPath) as! FeedViewCell
        let post = posts[indexPath.row]
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.postCaption?.text = post.caption
        cell.postImg?.image = UIImage(url: URL(string: post.imgURL ?? "none.png"))
        return cell
    }
}
extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}

