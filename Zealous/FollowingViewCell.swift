//
//  FollowingViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/4/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore

protocol CustomCellDelegate:class {
    func customcell(cell:FollowingViewCell, didTappedThe button:UIButton?, emailId: String)
}

class FollowingViewCell: UITableViewCell {
    

    var db: Firestore!
    var currentUser: WriteableUser? = nil
    @IBOutlet weak var unfollow: UIButton!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    var associatedEmail:String? = nil
    weak var cellDelegate:CustomCellDelegate?
    @IBAction func unfollowClicked(_ sender: Any) {
       
        //let followingVC = FollowingViewController()
       let settings = FirestoreSettings();
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        db.collection("users").getDocuments() { [self]
            (queryCollection, error) in
            if let err = error{
                print("error")
                return;
            } else {
        var foundDoc: QueryDocumentSnapshot? = nil;
        for document in queryCollection!.documents {
            if(document.get("username") as? String == self.Name.text){
                foundDoc = document;
                break
            }
        }
                associatedEmail = foundDoc?.get("email") as? String
                print(associatedEmail as Any)
                cellDelegate?.customcell(cell: self, didTappedThe: sender as?UIButton,  emailId: associatedEmail!)
    }
        }
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
