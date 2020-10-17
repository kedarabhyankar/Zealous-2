//
//  TopicsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/6/20.
//

import UIKit

protocol TopicCellDelegate:class {
    func topiccell(cell:TopicsViewCell, didTappedThe button:UIButton?, topicTitle: String)
}

class TopicsViewCell: UITableViewCell {

    @IBOutlet weak var follow: UIButton!
    
    @IBOutlet weak var name: UILabel!
    
    weak var cellDelegate:TopicCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func unfollowClicked(_ sender: Any) {
        cellDelegate?.topiccell(cell: self, didTappedThe: sender as?UIButton,  topicTitle: name.text!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
