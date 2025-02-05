//
//  PostUnderTopicViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/15/20.
//

import UIKit
import BRYXBanner

class PostUnderTopicViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var DisaplyedCommentUN: UILabel!
    
    @IBOutlet weak var DisplayedCommentText: UILabel!
    var id:String? = nil
    var currentUser: WriteableUser? = nil
    var delegate: TopicDelegate? = nil
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

    @IBAction func postCommentPressed(_ sender: Any) {
        let alreadyLike = Banner(title: "Enter Text Into Comment", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        //print("\(currentUser?.username ?? "username"): \(commentText.text! as String)")
        if ((commentText.text?.isEmpty) == true){
            self.showAndFocus(banner: alreadyLike)
            return
        }else{
        currentUser?.comment(comment: commentText.text! as String, postId: id!)
        commentText.text = ""
        }
    }
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    @IBAction func savePostPressed(_ sender: Any) {
        currentUser?.toggleSavedPost(postTitle: id!)
    }
    @IBAction func downVotePressed(_ sender: Any) {
        currentUser?.addDownVote(postTitle: id!)
    }
    @IBAction func upVotePressed(_ sender: Any) {
        currentUser?.addUpVote(postTitle: id!)
    }
}

