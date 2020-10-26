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
    
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var comments: UITableView!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    var id:String? = nil
    var currentUser: WriteableUser? = nil
    var currentPost: Post? = nil
    var userPosts: [Post] = []
    var numUpvotes = 0;
    var numDownvotes = 0;
    var isUpvoted: Bool = false;
    var isDownvoted: Bool = false;
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
    }
    
    @IBAction func upVotePressed ( sender: Any) {
        currentUser?.addUpVote(postTitle: id!)
        if(isDownvoted){
            isDownvoted = false;
            self.numDownvotes -= 1;
            currentUser?.removeDownvote(postTitle: postTitle.text!)
            downVote.tintColor = UIColor(named: "udiconcolor_not_pressed")
        }
        isUpvoted = true;
        self.numUpvotes += 1;
        upVote.tintColor = UIColor(named: "udiconcolor_pressed")
    }
    
    @IBAction func downVotePressed ( sender: Any) {
        currentUser?.addDownVote(postTitle: id!)
        if(isUpvoted){
            isUpvoted = false;
            self.numUpvotes -= 1;
            currentUser?.removeUpvote(postTitle: postTitle.text!)
            upVote.tintColor = UIColor(named: "udiconcolor_not_pressed")
        }
        isDownvoted = true;
        self.numDownvotes += 1;
        downVote.tintColor = UIColor(named: "udiconcolor_pressed")
    }
    @IBAction func postCommentPressed(_ sender: Any) {
    }
    
    @IBAction func savePostPressed(_ sender: Any) {
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
