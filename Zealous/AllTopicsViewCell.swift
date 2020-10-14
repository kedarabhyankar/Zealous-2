//
//  AllTopicsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit

class AllTopicsViewCell: UITableViewCell {

    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var follow: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
