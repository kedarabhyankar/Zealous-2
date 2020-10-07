//
//  TopicsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/6/20.
//

import UIKit

class TopicsViewCell: UITableViewCell {

    @IBOutlet weak var follow: UIButton!
    
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
