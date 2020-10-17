//
//  AllTopicsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit
protocol AllTopicsCellDelegate:class {
    func alltopics(cell:AllTopicsViewCell, didTappedThe button:UIButton?, topic: String)
}

class AllTopicsViewCell: UITableViewCell {

    @IBOutlet weak var topic: UILabel!
    @IBOutlet weak var follow: UIButton!
    weak var cellDelegate:AllTopicsCellDelegate?
    @IBAction func followClicked(_ sender: Any) {
        cellDelegate?.alltopics(cell: self, didTappedThe: sender as?UIButton,  topic: topic.text!)
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
