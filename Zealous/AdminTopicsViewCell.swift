//
//  AdminTopicsViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/12/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore

class AdminTopicsViewCell: UITableViewCell {
    @IBOutlet weak var topic: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteClicked(_ sender: Any) {
        var topicName = topic.text
        Topic.getTopic(topicTitle: topicName!, completion: getTopic)
    }
    
    func getTopic(theTopic: Topic) {
        var myTopic = theTopic
        let serialQ = DispatchQueue(label: "com.queue.serial")
        serialQ.sync {
        for aPost in theTopic.posts {
            myTopic.removePost(postId: aPost)
            //Post.deleteStoragePost(thePost: aPost, theUser: self.currentUser!)
            Post.deletePost(postId: aPost)
            
        }
        }
        
        Topic.deleteTopic(topicName: theTopic.title)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
