//
//  UserPostCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 9/28/20.
//

import UIKit

protocol ProfileCellDelegate:class {
    func profileCell(cell:UserPostCell, didTappedThe button:UIButton?)
}
class UserPostCell: UITableViewCell, UITableViewDelegate {
    
    var tableDelegate: ProfileTable? = nil

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
   
    weak var cellDelegate: ProfileCellDelegate?
    @IBOutlet weak var DisplayedCommentUserName: UILabel!
    
    @IBOutlet weak var DisplayedCommentText: UILabel!
    
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    var id:String? = nil
    var currentUser: WriteableUser? = nil
    var delegate: ProfileDelegate? = nil
        var currentPost: Post? = nil
        var userPosts: [Post] = []
        
        func getUser(currentUser: WriteableUser) {
            self.currentUser = currentUser
        }
    
        @IBAction func upVotePressed ( sender: Any) {
            delegate?.upvote(postId: id!)
            cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
        }
        @IBAction func downVotePressed ( sender: Any) {
            delegate?.downvote(postId: id!)
            cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
        }
    @IBAction func postCommentPressed(_ sender: Any) {
        print("\(currentUser?.username ?? "username"): \(commentText.text! as String)")
        currentUser?.comment(comment: commentText.text! as String, postId: id!)
        commentText.text = ""
        cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
    }
    
    @IBAction func savePostPressed(_ sender: Any) {
        
        /*currentUser?.toggleSavedPost(postTitle: id!)
        if tableDelegate != nil {
            tableDelegate?.remove(postId: id!)
        }*/
        print("USER PRESSED SAVE")
        delegate?.savePost(postId: id!)
        cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
    }
    @IBAction func deletePostPressed ( sender: Any) {
            //first get the post from the user
            WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: addPost)
        cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
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
