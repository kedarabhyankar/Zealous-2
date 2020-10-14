//

//  ProfileSettingsController.swift

//  Zealous

//

//  Created by Hannah Shiple on 9/17/20.

//



import UIKit

import SwiftUI

import Foundation

import FirebaseAnalytics

import Firebase

import FirebaseFirestore

import FirebaseStorage

import FirebaseAuth

import CodableFirebase



class ProfileSettingsViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var ChangeFName: UITextField!
    
    @IBOutlet weak var ChangeLName: UITextField!
    
    @IBOutlet weak var ChangeBio: UITextField!
    
    @IBOutlet weak var ChangeEmail: UITextField!
    
    @IBOutlet weak var ChangeUsername: UITextField!
    
    @IBOutlet weak var CurrPassword: UITextField!
    
    @IBOutlet weak var NewPassword: UITextField!
    
    @IBOutlet weak var ConfirmPassword: UITextField!
    
    @IBOutlet weak var NewProfilePic: UIImageView!
    
    
    var db: Firestore!
    
    var storage: Storage!
    
    var userID = Auth.auth().currentUser!.uid
    
    var userEmail = Auth.auth().currentUser?.email
    
    var currentUser: WriteableUser? = nil
    
    var finished = false
    
    var createdPosts: [Post] = []
    
    var following: [WriteableUser] = []
    
    var followers: [WriteableUser] = []
    
    var followedTopics: [Topic] = []
    
    var theTopic: Topic? = nil
    
    var image: UIImage?
    
    var imageExt: String?
    
    
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        CurrPassword.isSecureTextEntry = true
        NewPassword.isSecureTextEntry = true
        ConfirmPassword.isSecureTextEntry = true
        ChangeEmail.keyboardType = .emailAddress
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        userID = Auth.auth().currentUser!.uid
        userEmail = Auth.auth().currentUser?.email
        WriteableUser.getCurrentUser(completion: getUser)
        // WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: self.getPosts)
        //self.currentUser?.getFollowers(addUser: self.addFollower)
        //self.currentUser?.getFollowedUsers(addUser: self.addFollowed)
        //self.currentUser?.getFollowedTopics(addTopic: self.addTopic)
        
    }
    
     func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: self.getPosts)
        self.currentUser?.getFollowers(addUser: self.addFollower)
        self.currentUser?.getFollowedUsers(addUser: self.addFollowed)
        self.currentUser?.getFollowedTopics(addTopic: self.addTopic)
    }
    
    
    
    @IBAction func UploadProfilePic(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        NewProfilePic.image = self.image
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage
        if let possibleImage = info[.editedImage] as? UIImage{
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        } else {
            return;
        }
        self.image = image
        self.NewProfilePic.image = image
        self.imageExt = ".png"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SubmitProfilePic(_ sender: Any) {
        var photoURL: String = ""
        self.NewProfilePic.image = self.image
        print("self.image is: \(String(describing: self.image))")
        self.uploadImage((self.image!), completion: { (state, result) in
            if (!state) {
                print("error updating profile pic")
                self.NewProfilePic.image = nil
                return
            } else {
               photoURL = result
               self.currentUser?.pictureURL = photoURL
                let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
                self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
                self.NewProfilePic.image = nil
                return
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
    
    
    
    
    @IBAction func SubmitUserSettings(_ sender: Any) {
        //print("user id is: " + userID)
        let fname = ChangeFName.text ?? ""
        if (fname != "") {
            db.collection("users").document(userEmail!).updateData(["firstName":fname ])
            currentUser?.firstName = fname
            ChangeFName.text = ""
        }
        let lname: String = ChangeLName.text ?? ""
        if (lname != "") {
            db.collection("users").document(userEmail!).updateData(["lastName": lname])
            currentUser?.lastName = lname
            ChangeLName.text = ""
        }
        let changeBio: String = ChangeBio.text ?? ""
        if (changeBio != "") {
            db.collection("users").document(userEmail!).updateData(["bio": changeBio])
            currentUser?.bio = changeBio
            ChangeBio.text = ""
        }
        
        let email: String = ChangeEmail.text ?? ""
        if (email != "") {
            db.collection("users").document(userEmail!).updateData(["email": email])
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if let error = error {
                    print("Can't update email, error:  \(error)")
                } else {
                    self.currentUser?.email = email
                    print("Updated email sucess")
                }
            }
            ChangeEmail.text = ""
        }
        
        let username: String = ChangeUsername.text ?? ""
        if (username != "") {
            db.collection("users").document(userEmail!).updateData(["profile.username": username])
            currentUser?.username = username
            ChangeUsername.text = ""
        }
    }
    

    
    @IBAction func SubmitPassword(_ sender: Any) {
        
        let newPass: String = NewPassword.text ?? ""
        let currentPass: String = CurrPassword.text ?? ""
        let confirmPass: String = ConfirmPassword.text ?? ""
        var reauth: Bool =  false
        let email: String = (Auth.auth().currentUser?.email)!

        //let email: String = db.collection("users").document(userID).value(forKey: "email") as! String
        
        let creds = EmailAuthProvider.credential(withEmail: email, password: currentPass)
        
        //reauthenticate the user with the current password they entered and make sure it is correct
        
        Auth.auth().currentUser?.reauthenticate(with: creds, completion: { (result, error) in
            
            if let error = error {
                
                let alertController = UIAlertController(title: "\(error)", message: "Current password is incorrect.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                self.CurrPassword.text = ""
                
                self.NewPassword.text = ""
                
                self.ConfirmPassword.text = ""
                
                //return
                
            }
                
            else {
                
                //start of reauth being true
                
                reauth = true
                
                //self.CurrPassword.text = ""
                
                if (newPass == confirmPass && newPass != "" && confirmPass != "" && reauth == true) {
                    
                    let regex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z]).{8,}$")
                    
                    if (regex.evaluate(with: newPass) == false) {
                        
                        let alertController = UIAlertController(title: "Error", message: "Please Enter Valid Password", preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        self.CurrPassword.text = ""
                        
                        self.NewPassword.text = ""
                        
                        self.ConfirmPassword.text = ""
                        
                        return
                        
                    }
                    
                    Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in
                        
                        if let error = error {
                            
                            print("Can't update password, error:  \(error)")
                            
                        } else {
                            
                            let alertController = UIAlertController(title: "Sucess", message: "Password was changed.", preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            self.CurrPassword.text = ""
                            
                            self.NewPassword.text = ""
                            
                            self.ConfirmPassword.text = ""
                            
                            print("Updated password sucess")
                            
                            return
                            
                        }
                        
                    }
                    
                    
                    
                } else if ( !newPass.elementsEqual(confirmPass)) {
                    
                    let alertController = UIAlertController(title: "Error", message: "Make Sure Passwords Match", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.CurrPassword.text = ""
                    
                    self.NewPassword.text = ""
                    
                    self.ConfirmPassword.text = ""
                    
                    return
                    
                }
                
                
                
                //end of reauth being true
                
            }
            
        })
        
        
        
        
        
    }
    
    
    
    
    
    @IBAction func LogoutUser(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            
            //let storyboard = UIStoryboard(name:"Main", bundle:nil )
            
            //let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
            
            //present(vc, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "toMain", sender: self)
            
        }
            
        catch let error as NSError
            
        {
            
            print("Error logging out user" + error.localizedDescription)
            
        }
        
        
        
    }
    
    func getPosts(postArray: [Post]) {
        self.createdPosts = postArray
    }
    
    func addFollower(user: WriteableUser) {
        self.followers.append(user)
        var follower: WriteableUser = user
        follower.unfollow(email: self.currentUser!.email)
    }
    
    func addFollowed(user: WriteableUser) {
        self.following.append(user)
        self.currentUser?.unfollow(email: user.email)
    }
    
    func addTopic(topic: Topic) {
        self.followedTopics.append(topic)
    }
    
    func getTopic(thetopic: Topic) {
        DispatchQueue.main.async {
        self.theTopic = thetopic
        for aPost in self.createdPosts {
            if (self.theTopic!.posts.contains(aPost.postId)) {
                self.theTopic!.removePost(postId: aPost.postId)
                if (self.theTopic!.posts.count == 0) {
                    Topic.deleteTopic(topicName: self.theTopic!.title)
                }                //let index: Int? = self.theTopic!.posts.firstIndex(of: aPost.postId)
                //self.theTopic!.posts.remove(at: index!)
            }
        }
        //if the topic's post array is empty delete the topic
        print("topic post array count: \(self.theTopic!.posts.count)")
        if (self.theTopic!.posts.count == 0) {
            Topic.deleteTopic(topicName: self.theTopic!.title)
        }
        }
        
    }
    
    
    
    
    
    @IBAction func DeleteUser(_ sender: Any) {
        
        
        
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertController.Style.alert)
        
        
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            
            //user wants to delete their account
            
            //delete all of their posts from the topic's post array
           /* WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: self.userCreatedPosts)
            for aPost in self.userPosts {
                let deleteVc = DeletePostViewController()
                deleteVc.DeletePostId(thePost: aPost)
            } */
             let serialQueue = DispatchQueue(label: "com.queue.serial")
            
           /* serialQueue.sync {
            //fill all the user arrays
            WriteableUser.getCreatedPosts(email: self.currentUser!.email, completion: self.getPosts)
            self.currentUser?.getFollowers(addUser: self.addFollower)
            self.currentUser?.getFollowedUsers(addUser: self.addFollowed)
            self.currentUser?.getFollowedTopics(addTopic: self.addTopic)
            } */
            
            serialQueue.sync {
            //for each post in the user's created post array, delete it
            print("createdPosts: \(self.createdPosts)")
            for aPost in self.createdPosts {
                //let deleteVC = DeletePostViewController()
                //deleteVC.DeletePostId(thePost: aPost)
                Topic.getTopic(topicTitle: aPost.topic, completion: self.getTopic)
                Post.deleteStoragePost(thePost: aPost, theUser: self.currentUser!)
                Post.deletePost(postId: aPost.postId)
            }
        }
            serialQueue.sync {
            //for each topic the user follows, unfollow it
            print("followedTopics: \(self.followedTopics)")
            for aTopic in self.followedTopics {
                self.currentUser?.unfollowTopic(title: aTopic.title)
            }
            }
            
            print("Above is done")
            
            //delete all user photos from storage
            let ref = Storage.storage().reference()
            let imageRef = ref.child("media/" + (self.currentUser?.email)! + "/profile.jpeg")
            imageRef.delete { error in
                if let error = error {
                    print("error deleting user from storage \(error)")
                } else {
                    print("sucess deleting user from stroage")
                }
            }
            
            
            let user = Auth.auth().currentUser
            
            self.db.collection("users").document((self.currentUser?.email)!).delete() {
                error in
                if (error != nil) {
                    print("error deleting user from firestore \(String(describing: error))")
                } else {
                    print("success deleting user from firestore")
                }
            }
            
            user?.delete { error in
                
                if let error = error {
                    
                    print("Error deleting user \(error)")
                    
                } else {
                    
                    //let storyboard = UIStoryboard(name:"Main", bundle: nil)
                    
                    //let vc = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
                    print("success deleting user from auth")
                    
                    self.performSegue(withIdentifier: "toMain", sender: self)
                    
                    //self.present(vc, animated: true, completion: nil)
                    
                }
                
            }
   // }
            
        }))
        
        
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
            //user does not want to delete their account
            
            deleteAlert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        present(deleteAlert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    
    
}


