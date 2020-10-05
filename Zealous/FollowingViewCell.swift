//
//  FollowingViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/4/20.
//

import UIKit

class FollowingViewCell: UITableViewCell {

    @IBOutlet weak var unfollow: UIButton!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBAction func unfollowClicked(_ sender: Any) {
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
