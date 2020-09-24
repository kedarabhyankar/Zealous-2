//
//  BioAndProfileViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class BioAndProfileViewController: UIViewController {
    
    var finalProfile: Profile!
    var db : Firestore!
    var storage: Storage!
    var imageFormat: [String]!
    var dateFormat: DateFormatter!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var profileField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        dateFormat = DateFormatter()
        self.dateFormat.dateStyle = .short
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let biog = bioField.text ?? "This user does not have a bio."
        let prof = profileField.text ?? "This user does not have a profile."
        
        let storageRef = storage.reference()
        let uuid = UUID().uuidString
        var imagePath = uuid
        imagePath.append(".")
        imagePath.append(imageFormat[1])
        var imageDirPath = "images/"
        imageDirPath.append(uuid)
        imageDirPath.append(".")
        imageDirPath.append(imageFormat[1])
        let pictureRef = storageRef.child(imagePath)
        
        let data = Data()
        _ = pictureRef.putData(data, metadata: nil) {
            (metadata, error) in
            
            pictureRef.downloadURL{
                (url, error) in
                guard let downloadURL = url else {
                    var ref : DocumentReference? = nil
                    ref = self.db.collection("users").addDocument(data: [
                                                                    "firstName":self.finalProfile.firstName,
                                                                    "lastName":self.finalProfile.lastName,
                                                                    "username":self.finalProfile.username,
                                                                    "email":self.finalProfile.email,
                                                                    "bio":biog,
                                                                    "interests":prof,
                                                                    "dob": self.dateFormat.string(from: self.finalProfile.dateOfBirth),
                                                                    "pictureURL": url?.absoluteString ?? "BAD PROFILE IMAGE URL"]){
                        err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                    return;
                }
                
                var ref : DocumentReference? = nil
                ref = self.db.collection("users").addDocument(data: [
                                                                "firstName":self.finalProfile.firstName,
                                                                "lastName":self.finalProfile.lastName,
                                                                "username":self.finalProfile.username,
                                                                "email":self.finalProfile.email,
                                                                "bio":biog,
                                                                "interests":prof,
                                                                "dob": self.dateFormat.string(from: self.finalProfile.dateOfBirth),
                                                                "pictureURL": downloadURL ]){
                    err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

struct FinishedProfile {
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let bio: String
    let interests: String
    let dob: String
    let pictureURL: String
}
