//
//  AdminProfileViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/15/20.
//

import UIKit

class AdminProfileViewCell: UITableViewCell {

    @IBOutlet weak var DisplayedCommentText: UILabel!
    @IBOutlet weak var DisplayedCommentUserName: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    var id:String? = nil
    var currentUser: WriteableUser? = nil
    var delegate: ProfileDelegate? = nil
        var currentPost: Post? = nil
        var userPosts: [Post] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
