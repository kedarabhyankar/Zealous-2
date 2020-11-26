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

class TimelineViewController: UIViewController, TimelineDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    var selectedFilter:String = "All"
    var selectedSort:String = "Time"
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == filterBar {
             selectedFilter = picker1Options[row]
        } else {
             selectedSort = picker2Options[row]
        }
        if(selectedFilter != "All") {
            postsFinal.removeAll()
            for p in posts {
                if(p.topic == selectedFilter) {
                    postsFinal.append(p);
                }
            }
        }
        if(selectedFilter == "All") {
            postsFinal.removeAll()
            postsFinal = posts
        }
        timelineTableView.reloadData()
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == filterBar {
                return picker1Options.count
            } else {
                return picker2Options.count
            }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == filterBar {
                return "\(picker1Options[row])"
            } else {
                return "\(picker2Options[row])"
            }
    }
    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var filterBar: UIPickerView!
    @IBOutlet weak var sortBar: UIPickerView!
    var picker1Options:[String] = [String]()
    var picker2Options:[String] = [String]()
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var following: [WriteableUser] = []
    var posts: [Post] = []
    var postsFinal: [Post] = []
    var topics: [Topic] = []
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    var numBlockedPosts: Int = 0
    var currPost: Post? = nil
    var path: String = ""
    var path2: String = ""
    var allTopicsArray: [Topic] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
        timelineTableView.rowHeight = 620
        timelineTableView.estimatedRowHeight = 620
        self.sortBar.delegate = self
        self.sortBar.dataSource = self
        self.filterBar.delegate = self
        self.filterBar.dataSource = self
        picker1Options = ["All","Comments","Dog","Purdue","Test","Test3","Waterfall","anonymous"]
        picker2Options = ["Time", "Relevance", "Engagement", "Comments"]
        timelineTableView.reloadData()
    }

    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        //afterGettingCurrentUser()
       // WriteableUser.getCreatedPosts(email: currentUser.email, completion: printUserPosts)
        currentUser.getLikedPosts(addPost: addPost) // populates the likedPosts array
        currentUser.getFollowedUsers(addUser: addUser) // populates the following array
        currentUser.getFollowedTopics(addTopic: addTopic)
        timelineTableView.reloadData()
    }
    func addTimeline(postArray: [Post]) {
        for postItem in postArray {
            if !currentUser!.blockedBy.contains(postItem.creatorId) {
                posts.append(postItem)
            }
            print(postItem)
        }
        postsFinal = posts
        timelineTableView.reloadData()
    }
    func addTopic(topic: Topic) {
        topics.append(topic)
        topic.getPosts { (post) in
            for postItem in self.posts {
                if (postItem.postId == post.postId) {
                    return
                }
            }
            if !self.currentUser!.blockedBy.contains(post.creatorId) {
                self.posts.append(post)
                self.timelineTableView.reloadData()
            }
        }
    }
    
    func printUserPosts(postArray: [Post]) {
        for post in postArray {
            print(post)
        }
    }
    
    func addPost(likedPost: Post) {
        likedPosts.append(likedPost)
        timelineTableView.reloadData()
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
        return self.postsFinal.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Sort the posts by timestamp
        if(selectedFilter == "All") {
            postsFinal = posts
        }
        if(selectedSort == "Time") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
               })
        }
        if(selectedSort == "Engagement") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                first.likes > second.likes
               })
        }
        if(selectedSort == "Comments") {
            postsFinal.sort(by: { (first: Post, second: Post) -> Bool in
                first.comments.count > second.comments.count
               })
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedView", for: indexPath) as! FeedViewCell
        let post = postsFinal[indexPath.row]
        currPost = post
        
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
        cell.cellDelegate = self
        path = "media/" + (post.creatorId) + "/" +  (post.title) + "/" +  "pic.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.postImg?.image = UIImage(data: data!)
            }
        }
        let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
        path2 = "media/" + post.creatorId + "/" + "profile.jpeg"
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.profilePic?.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toSinglePost", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CommentsViewController
        {
            let vc = segue.destination as? CommentsViewController
            vc?.comments = commentList
        }
        if segue.identifier == "toSinglePost" {
            let viewController = segue.destination as! SinglePostViewController
            if currPost!.comments.isEmpty{
                firstCommentUN = ""
                firstCommentText = ""
            }else{
            let firstComment: String = (currPost?.comments[0])!
                firstCommentUN = firstComment.components(separatedBy: ": ")[0]
                firstCommentText = firstComment.components(separatedBy: ": ")[1]
            }
            print("CURR POSTT")
            print(currPost?.creatorId)
            viewController.usernameText = currPost!.creatorId
            viewController.commentsList = commentList
            viewController.postCaptionText = currPost!.caption
            viewController.postTitleText = currPost!.title
            viewController.DisplayedCommentUserNameText = firstCommentUN
            viewController.DisplayedCommentTextText = firstCommentText
            viewController.postID = currPost!.postId
            let ref = Storage.storage().reference(withPath: path)
            
            ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error: Image could not download!")
                } else {
                    viewController.postImage?.image = UIImage(data: data!)
                }
            }
            let ref2 = Storage.storage().reference(withPath: path2)
            ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error: Image could not download!")
                } else {
                    viewController.profilePicture?.image = UIImage(data: data!)
                }
            }
        
        }
    }
}
extension TimelineViewController: FeedCellDelegate {
    func feedCell(cell: FeedViewCell, didTappedThe button: UIButton?) {
        self.performSegue(withIdentifier: "toSelf", sender: self)
        print("REFRESH!!!!")
    }
}


