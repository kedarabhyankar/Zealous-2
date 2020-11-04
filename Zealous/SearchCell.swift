//
//  SearchCell.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 11/4/20.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var searchUsernameLabel: UILabel!
    @IBOutlet weak var searchTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
