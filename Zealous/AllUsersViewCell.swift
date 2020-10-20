//
//  AllUsersViewCell.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner
import FirebaseFirestore

protocol AllUsersCellDelegate:class {
    func allusers(cell:AllUsersViewCell, didTappedThe button:UIButton?, emailId: String)
}

class AllUsersViewCell: UITableViewCell {
    weak var cellDelegate:AllUsersCellDelegate?
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var username: UILabel!
    var db: Firestore!
    var associatedEmail:String? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func followClicked(_ sender: Any) {
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
             if(document.get("username") as? String == self.username.text){
                 foundDoc = document;
                 break
             }
         }
                 associatedEmail = foundDoc?.get("email") as? String
                 print(associatedEmail as Any)
                 cellDelegate?.allusers(cell: self, didTappedThe: sender as?UIButton,  emailId: associatedEmail!)
     }
         }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
