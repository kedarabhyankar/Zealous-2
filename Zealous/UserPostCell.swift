//
//  UserPostCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 9/28/20.
//

import UIKit

class UserPostCell: UITableViewCell, UITableViewDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        WriteableUser.getCurrentUser(completion: getUser)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
        @IBOutlet weak var postImage: UIImageView!
        @IBOutlet weak var profilePicture: UIImageView!
        @IBOutlet weak var username: UILabel!
        @IBOutlet weak var postTitle: UILabel!
        @IBOutlet weak var postCaption: UILabel!
        @IBOutlet weak var deletePost: UIButton!
        @IBOutlet weak var upVote: UIButton!
        @IBOutlet weak var downVote: UIButton!
        @IBOutlet weak var comments: UIButton!
    
        var currentUser: WriteableUser? = nil
        var currentPost: Post? = nil
        var userPosts: [Post] = []
        
        func getUser(currentUser: WriteableUser) {
            self.currentUser = currentUser
        }
    
        @IBAction func upVotePressed ( sender: Any) {
            
        }
        @IBAction func downVotePressed ( sender: Any) {
            
        }
        @IBAction func commentPressed ( sender: Any) {
            
        }
        @IBAction func deletePostPressed ( sender: Any) {
            //first get the post from the user
            WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: addPost)
        }
    
    func addPost(userPosts: [Post]) {
        let serialQueue = DispatchQueue(label: "com.queue.serial")
        serialQueue.sync {
        for post in userPosts {
            if (post.title == self.postTitle.text && post.caption == self.postCaption.text) {
                self.currentPost = post
                print("current post HERE: \(String(describing: self.currentPost))")
                let deleteVC = DeletePostViewController()
                deleteVC.DeletePostId(thePost: self.currentPost!)
            }
        }
        }
        print("IN ADD POST")
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        //return
        
    }

}
