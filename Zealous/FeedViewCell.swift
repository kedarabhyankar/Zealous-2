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

protocol FeedCellDelegate:class {
    func feedCell(cell:FeedViewCell, didTappedThe button:UIButton?)
}

class FeedViewCell: UITableViewCell {
    
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var DisplayedCommentUserName: UILabel!
    @IBOutlet weak var DisplayedCommentText: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var down: UIButton!
    @IBOutlet weak var up: UIButton!
    @IBOutlet weak var username: UILabel!
    var id: String? = nil
    var currentUser: WriteableUser? = nil
    var delegate: TimelineDelegate? = nil
    weak var cellDelegate:FeedCellDelegate?
    
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
        delegate?.savePost(postId: id!)
    }
    
    @IBAction func postCommentPressed(_ sender: Any) {
        let alreadyLike = Banner(title: "Enter Text Into Comment", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        
       // print("\(currentUser?.username ?? "username"): \(commentText.text! as String)")
        if ((commentText.text?.isEmpty) == true){
            self.showAndFocus(banner: alreadyLike)
            return
        }else{
        currentUser?.comment(comment: commentText.text! as String, postId: id!)
        commentText.text = ""
        cellDelegate?.feedCell(cell: self, didTappedThe: sender as? UIButton)
        }
    }
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    @IBAction func downVotePressed(_ sender: Any) {
        delegate?.downvote(postId: id!)
    }
    @IBAction func upVotePressed(_ sender: Any) {
        delegate?.upvote(postId: id!)
    }
    
}
