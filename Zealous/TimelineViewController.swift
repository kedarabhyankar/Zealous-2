//
//  TimelineViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/5/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

protocol TimelineDelegate {
    func savePost(postId: String)
    func downvote(postId: String)
    func upvote(postId: String)
}

class TimelineViewController: UIViewController, TimelineDelegate {

    

    @IBOutlet weak var timelineTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var following: [WriteableUser] = []
    var posts: [Post] = []
     var topics: [Topic] = []
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
        timelineTableView.rowHeight = 620
        timelineTableView.estimatedRowHeight = 620
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        //afterGettingCurrentUser()
       // WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedUsers(addUser: addUser) // populates the following array
        currentUser.getFollowedTopics(addTopic: addTopic)
        //GET FIRST COMMENT FROM DB and set to firstCOMMENTUN/TEXT
        
        if !posts.isEmpty {
            posts.sort(by: {$0.timestamp > $1.timestamp})
        }
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
    
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postTitle: postId)
    }
    func downvote(postId: String) {
        currentUser?.addDownVote(postTitle: postId)
    }
    
    func upvote(postId: String) {
        currentUser?.addUpVote(postTitle: postId)
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
        commentList.removeAll()
        commentList = post.comments
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.postCaption?.text = post.caption
        cell.id = post.postId
        if post.comments.isEmpty{
            firstCommentUN = ""
            firstCommentText = ""
        }else{
        let firstComment: String = post.comments[0]
            firstCommentUN = firstComment.components(separatedBy: ": ")[0]
            firstCommentText = firstComment.components(separatedBy: ": ")[1]
        }
        cell.DisplayedCommentUserName?.text = firstCommentUN
        cell.DisplayedCommentText?.text = firstCommentText
        //get comments
        print(post.comments)
        cell.delegate = self

        let path = "media/" + (post.creatorId) + "/" +  (post.title) + "/" +  "pic.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.postImg?.image = UIImage(data: data!)
            }
        }
        let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.profilePic?.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CommentsViewController
        {
            let vc = segue.destination as? CommentsViewController
            vc?.comments = commentList
        }
    }
}


