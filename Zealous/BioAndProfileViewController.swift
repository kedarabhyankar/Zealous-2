//
//  BioAndProfileViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class BioAndProfileViewController: UIViewController {
    
    var finalProfile: Profile!
    var db : Firestore!
    var storage: Storage!
    var dateFormat: DateFormatter!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var profileField: UITextField!
    var defaultImage: UIImage!
    let unknownErrorBanner = Banner(title: "Something went wrong!", subtitle: "An unknown error occurred.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
    let successBanner = Banner(title: "Successfully uploaded your profile photo!", subtitle: "Your profile photo was successfully uploaded!", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)
    let bannerDisplayTime = 3.0
    let df = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        dateFormat = DateFormatter()
        self.dateFormat.dateStyle = .short
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        defaultImage = UIImage(systemName: "person.crop.circle") //sf symbols default image
        // Do any additional setup after loading the view.
        df.dateStyle = .short
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let biog = bioField.text ?? "This user does not have a bio."
        let profile = profileField.text ?? "This user does not have a profile."
        var photoURL: String = ""
        uploadImage((self.finalProfile.picture ?? self.defaultImage), completion: { (state, result) in
            if(!state){
                self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                return
            } else {
                photoURL = result
                
                let writeableUser = WriteableUser(firstName: self.finalProfile.firstName, lastName: self.finalProfile.lastName, username: self.finalProfile.username, email: self.finalProfile.email, bio: biog, interests: profile.components(separatedBy: ","), dob: self.df.string(from: self.finalProfile.dateOfBirth), pictureURL: photoURL, createdPosts:[], likedPosts:[], dislikePosts:[], followedUsers:[], followers:[], savedPosts:[])
                        
                let dataToWrite = try! FirestoreEncoder().encode(writeableUser)
                self.db.collection("users").document(self.finalProfile.email).setData(dataToWrite) { error in
                    
                    if(error != nil){
                        print("error happened when writing to firestore!")
                        print("described error as \(error!.localizedDescription)")
                        self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                        return
                    } else {
                        print("successfully wrote document to firestore with document id \(self.finalProfile.email)")
                        self.performSegue(withIdentifier: "toTimeline", sender: self)
                    }
                }
            }
        })
        

        
    }
    
    func uploadImage(_ image: UIImage,
                     completion: @escaping (_ hasFinished: Bool, _ url: String) -> Void) {
        let data: Data = image.jpegData(compressionQuality: 1.0)!
        
        // ref should be like this
        let ref = Storage.storage().reference(withPath: "media/" + (Auth.auth().currentUser?.email)! + "/" + "profile.jpeg")
        ref.putData(data, metadata: nil,
                    completion: { (meta , error) in
                        if error == nil {
                            // return url
                            ref.downloadURL(completion: { (url, error) in
                                if(error != nil){
                                    print("some error happened described here \(error!.localizedDescription)")
                                    completion(false, "")
                                } else {
                                    completion(true, url!.absoluteString)
                                }
                            })
                        }
                    })
    }
}


struct WriteableUser: Codable {
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var bio: String
    var interests: [String] //followed Topics
    let dob: String
    var pictureURL: String
    var createdPosts: [String]
    var likedPosts: [String] // stores postId's
    var dislikePosts: [String]
    var followedUsers: [String] // stores creatorId's
    var followers: [String] // stores creatorId's
    var savedPosts: [String]
}

