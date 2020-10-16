//
//  FollowersTableViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/4/20.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
   
    @IBOutlet weak var Profilepic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
