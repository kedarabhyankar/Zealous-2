//
//  FeedViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 9/28/20.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class FeedViewCell: UITableViewCell {
    
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var comments: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var down: UIButton!
    @IBOutlet weak var up: UIButton!
    @IBOutlet weak var username: UILabel!
    var id: String? = nil
    var currentUser: WriteableUser? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func savePostPressed(_ sender: Any) {
        if currentUser?.savedPosts.contains(id!) == true {
            currentUser?.removeSavedPost(postTitle: id!)
        }
        else {
            currentUser?.addSavedPost(postTitle: id!)
        }
    }
    
    @IBAction func postCommentPressed(_ sender: Any) {
    }
    
    @IBAction func downVotePressed(_ sender: Any) {
        currentUser?.addDownVote(postTitle: id!)
    }
    @IBAction func upVotePressed(_ sender: Any) {
        currentUser?.addUpVote(postTitle: id!)
    }
    
}
