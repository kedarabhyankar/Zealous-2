//
//  PostUnderTopicViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/15/20.
//

import UIKit

class PostUnderTopicViewCell: UITableViewCell {

    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var comments: UITableView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func postCommentPressed(_ sender: Any) {
    }
    @IBAction func savePostPressed(_ sender: Any) {
    }
    @IBAction func downVotePressed(_ sender: Any) {
    }
    @IBAction func upVotePressed(_ sender: Any) {
    }
}

