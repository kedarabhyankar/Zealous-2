//
//  AdminUsersViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/12/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore


class AdminUsersViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    var db: Firestore!
    var associatedEmail:String? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteClicked(_ sender: Any) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
