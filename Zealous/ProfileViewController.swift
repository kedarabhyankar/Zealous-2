//
//  ProfileViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/12/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

protocol ProfileTable {
    func remove(postId: String)
}
protocol ProfileDelegate {
    func savePost(postId: String)
    func downvote(postId: String)
    func upvote(postId: String)
}

class ProfileViewController: UIViewController, ProfileDelegate {
    func savePost(postId: String) {
        currentUser?.toggleSavedPost(postTitle: postId)
    }
    
    func downvote(postId: String) {
        currentUser?.addDownVote(postTitle: postId)
    }
    
    func upvote(postId: String) {
        currentUser?.addUpVote(postTitle: postId)
    }
    

    @IBOutlet weak var createPostButtom: UIButton!
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var interestsButton: UIButton!
    
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    @IBOutlet weak var navigationBarPosts: UISegmentedControl!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var loggedInUser: WriteableUser? = nil
    var isBlocked: Bool = false
    var currentUser: WriteableUser? = nil
    var profilePosts: [Post] = []
    var isThisUser: Bool = true
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    var currPost: Post? = nil
    var path: String = ""
    var path2: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        if currentUser == nil {
            WriteableUser.getCurrentUser(completion: getUser)
            isThisUser = true
        }
        else {
            getUser(currentUser: currentUser!)
            isThisUser = false
            createPostButtom.isHidden = true
            editProfileButton.isHidden = true
            self.followersButton.isHidden = true
            self.followingButton.isHidden = true
//            self.interestsButton.isHidden = true
            if loggedInUser!.blockedBy.contains(currentUser!.email) {
                let alertController = UIAlertController(title: "User has blocked you", message: "User has blocked you, you will not be able to view their profile until they unblock you", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            let button = UIButton(frame: self.interestsButton.frame)
            button.backgroundColor = self.interestsButton.backgroundColor
            if loggedInUser!.blocked.contains(currentUser!.email) {
                button.setTitle("Unblock", for: .normal)
                isBlocked = true
            }
            else {
                button.setTitle("Block", for: .normal)
                isBlocked = false
            }
            button.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
            self.view.addSubview(button)
        }
        profileTableView.rowHeight = 620
        profileTableView.estimatedRowHeight = 620
        profileTableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    @objc func blockButtonTapped() {
        if !isBlocked {
            loggedInUser?.block(email: currentUser!.email)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            loggedInUser?.unblock(email: currentUser!.email)
            print("unblock user")
        }
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        //profileTableView.delegate = self
        //profileTableView.dataSource = self
        print("IN LOAD LIST")
        self.performSegue(withIdentifier: "toProfile", sender: self)
        //WriteableUser.getCurrentUser(completion: getUser(currentUser:))
        //profileTableView.reloadData()
    }
    
    
    func getUser(currentUser: WriteableUser) {
        print("getUser")
        self.currentUser = currentUser
        bio.text = currentUser.bio
        username.text = currentUser.username
        name.text = currentUser.firstName + " " + currentUser.lastName
        let path = "media/" + (currentUser.email) + "/" +  "profile.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                self.profilePic.image = UIImage(data: data!)
            }
        }
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: addPost)
        
        //currentUser.getProfilePosts(addPost: addPost) // populates the likedPosts array
        afterGettingCurrentUser()
        
    }
    
    func afterGettingCurrentUser() {
//        currentUser?.follow(email: "ramesh32@purdue.edu")
        print(currentUser?.followers ?? "")
    }
    
    
    func addPost(postArray: [Post]) {
        for post in postArray {
            profilePosts.append(post)
            profileTableView.reloadData()
        }
    }
    
    func addPostArray(post: Post){
        profilePosts.append(post)
        profileTableView.reloadData()
    }
    
    
    @IBAction func indexChanged() {
        switch navigationBarPosts.selectedSegmentIndex{
        case 0:
            //Primary Posts
            profilePosts.removeAll()
            WriteableUser.getCreatedPosts(email: (currentUser?.email)!, completion: addPost)
        case 1:
            //All Interactions
            profilePosts.removeAll()
            currentUser?.getLikedPosts(addPost: addPostArray)
            currentUser?.getDislikePosts(addPost: addPostArray)
        case 2:
            //Saved Posts
            print("SAVED POSTS")
            profilePosts.removeAll()
            currentUser?.getSavedPosts(addPost: addPostArray)
            print("saved printed")
            print(profilePosts.count)
        default:
            print("Default")
            profilePosts.removeAll()
            WriteableUser.getCreatedPosts(email: (currentUser?.email)!, completion: addPost)
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profilePosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        profilePosts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
        })
        profilePosts = profilePosts.filter { post in
            return !post.madeAnonymously
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath) as! UserPostCell
        print(indexPath.row)
        
        for i in 0..<profilePosts.count {
            print("print")
            print(profilePosts[i].postId)
        }
        let post = profilePosts[indexPath.row]
        currPost = post
        commentList.removeAll()
        commentList = post.comments
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.postCaption?.text = post.caption
        cell.id = post.postId
        // COMMENTS
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
        //END COMMENTS
        if post.creatorId != currentUser?.email {
            cell.deletePost.isHidden = true
        }
        else{
            cell.deletePost.isHidden = false
        }
        cell.delegate = self
        cell.cellDelegate = self
        cell.tableDelegate = self
        if !isThisUser {
            cell.deletePost.isHidden = true
            cell.savePost.isHidden = true
        }
        path = "media/" + (post.creatorId) + "/" +  (post.title) + "/" +  "pic.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.postImage?.image = UIImage(data: data!)
            }
        }
        let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
        path2 = "media/" + post.creatorId + "/" + "profile.jpeg"
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.profilePicture?.image = UIImage(data: data!)
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

extension ProfileViewController: ProfileTable {
    func remove(postId: String) {
        for i in 0..<profilePosts.count {
            if profilePosts[i].postId == postId {
                if i < profilePosts.count {
                    profilePosts.remove(at: i)
                }
            }
        }
        print(profilePosts)
        profileTableView.reloadData()
    }
}
extension ProfileViewController: ProfileCellDelegate {
    func profileCell(cell:UserPostCell, didTappedThe button: UIButton?) {
        self.performSegue(withIdentifier: "toSelfP", sender: self)
        print("REFRESH!!!!")
    }
}
