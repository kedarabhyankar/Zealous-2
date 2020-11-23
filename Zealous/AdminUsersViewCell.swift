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
    var currentUser: WriteableUser? = nil
    @IBOutlet weak var delete: UIButton!
    var db: Firestore!
    var associatedEmail:String? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    
    
    @IBAction func deleteClicked(_ sender: Any) {
        let usernameTxt = username.text
        self.associatedEmail = nil
        
       // while (self.associatedEmail == nil) {
            WriteableUser.getEmail(username: usernameTxt!, completion: { [self] result in
                if result != nil && result != "" {
                    self.associatedEmail = result
                    print("associated email: " + associatedEmail!)
                    WriteableUser.getAUser(theEmail: self.associatedEmail!, completion: self.getUser)
                    //return
                }
            })
       // }
    }
    
    func getUser(currentUser: WriteableUser) {
       self.currentUser = currentUser
       //WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: self.getPosts)
       //self.currentUser?.getFollowers(addUser: self.addFollower)
       //self.currentUser?.getFollowedUsers(addUser: self.addFollowed)
      // self.currentUser?.getFollowedTopics(addTopic: self.addTopic)
        WriteableUser.deleteUser(theUser: currentUser)
    }
    
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
