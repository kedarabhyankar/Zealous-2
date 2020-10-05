//
//  FeedViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 9/28/20.
//

import UIKit

class FeedViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var comments: UIButton!
    @IBOutlet weak var down: UIButton!
    @IBOutlet weak var up: UIButton!
    @IBOutlet weak var username: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    
}
