//
//  PostsUnderTopicViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/15/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

protocol TopicDelegate {
    func savePost(postId: String)
    func downvote(postId: String)
    func upvote(postId: String)
}

class PostsUnderTopicViewController: UIViewController, TopicDelegate {
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postTitle: postId)
    }
    
    func downvote(postId: String) {
        currentUser?.addDownVote(postTitle: postId)
    }
    
    func upvote(postId: String) {
        currentUser?.addUpVote(postTitle: postId)
    }
    

    @IBOutlet weak var topicName: UILabel!
    @IBOutlet weak var postTableView: UITableView!
    var topic: Topic? = nil
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var following: [WriteableUser] = []
    var posts: [Post] = []
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
        addPosts()
        posts.sort(by: {$0.timestamp > $1.timestamp})
        postTableView.rowHeight = 620
        postTableView.estimatedRowHeight = 620
        self.postTableView.reloadData()
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        //afterGettingCurrentUser()
       //WriteableUser.getCreatedPosts(email: currentUser.email, completion: addPosts)
        posts.sort(by: {$0.timestamp > $1.timestamp})
        postTableView.reloadData()
    }
    func setTopic(topicName: Topic) {
        //print(topicName)
        self.topic = topicName
    }
    func addPosts() {
        topic?.getPosts { (post) in
            self.posts.append(post)
            //print(post)
            self.postTableView.reloadData()
        }
        topicName.text = topic?.title
    }
    
}

extension PostsUnderTopicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Sort the posts by timestamp
        posts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTopic", for: indexPath) as! PostUnderTopicViewCell
        let post = posts[indexPath.row]
        print(post)
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
        cell.DisaplyedCommentUN?.text = firstCommentUN
        cell.DisplayedCommentText?.text = firstCommentText
        cell.delegate = self
        let path = "media/" + (post.creatorId) + "/" +  (post.title) + "/" +  "pic.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                //print("Error: Image could not download!")
            } else {
                cell.postImage?.image = UIImage(data: data!)
            }
        
            let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
            ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error: Image could not download!")
                } else {
                    cell.profilePicture?.image = UIImage(data: data!)
                }
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



