//
//  AdminPostsViewCell.swift
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


class AdminPostsViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var DisplayedCommentText: UILabel!
    @IBOutlet weak var DisaplyedCommentUN: UILabel!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    var currentUser: WriteableUser? = nil
    var id:String? = nil
    var delegate: TopicDelegate? = nil
    var currentPost: Post? = nil
    var userPosts: [Post] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deletePostClicked(_ sender: Any) {
        print("delete clicked")
        var email: String = username.text!
        //WriteableUser.getEmail(username: username2, completion: afterEmail)
        WriteableUser.getAUser(theEmail: email, completion: getUser)    }
    
    func afterEmail(email: String) {
        WriteableUser.getAUser(theEmail: email, completion: getUser)
    }
    
    func getUser(theUser: WriteableUser) {
        currentUser = theUser
        WriteableUser.getCreatedPosts(email: currentUser!.email, completion: addPost)
    }
    
    func addPost(userPosts: [Post]) {
        self.userPosts = userPosts
        print("user posts: \(self.userPosts)")
        let serialQueue = DispatchQueue(label: "com.queue.serial")
        serialQueue.sync {
        for post in userPosts {
            if (post.title == self.postTitle.text && post.caption == self.postCaption.text) {
                self.currentPost = post
                print("current post HERE: \(String(describing: self.currentPost))")
                let deleteVC = DeletePostViewController()
                deleteVC.DeletePostId(thePost: self.currentPost!, theUser: currentUser!)
            }
        }
        }
        print("IN ADD POST")
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        //return
        
    }
    
    
    
    @IBOutlet weak var delete: UIButton!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
