//
//  AdminPostsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/12/20.
//

import UIKit

class AdminPostsViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var DisplayedCommentText: UILabel!
    @IBOutlet weak var DisaplyedCommentUN: UILabel!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    var id:String? = nil
    var delegate: TopicDelegate? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
