//
//  CreatePostViewController.swift
//  Zealous
//
//  Created by Hannah Shiple on 9/29/20.
//
import Foundation
import UIKit
import SwiftUI
import Foundation
import FirebaseAnalytics
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

class CreatePostViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    
    @IBOutlet weak var PostTitle: UITextField!
    @IBOutlet weak var PostTopic: UITextField!
    @IBOutlet weak var PostCaption: UITextField!
    @IBOutlet weak var PostImage: UIImageView!
    var imageExt: String?
    var image: UIImage?
    var currentUser: WriteableUser? =  nil
    var currentPost: Post? = nil
    var currentTopic: Topic? = nil
    var defaultImage: UIImage!
    var finalProfile: Profile!
    var imgURL: String = ""
    
    
    var db: Firestore!
    var storage: Storage!
    var userID = Auth.auth().currentUser!.uid
    let unknownErrorBanner = Banner(title: "Something went wrong!", subtitle: "An unknown error occurred.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
    let successBanner = Banner(title: "Successfully uploaded your profile photo!", subtitle: "Your profile photo was successfully uploaded!", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)    //var userID = UUID().uuidString
    let bannerDisplayTime = 3.0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        storage = Storage.storage()
        defaultImage = UIImage(systemName: "person.crop.circle")
        userID = Auth.auth().currentUser!.uid
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
    }
    
    func getTheTopic(currentTopic: Topic) {
        DispatchQueue.main.async {
            self.currentTopic = currentTopic
            print("current topic in getTheTopic: \(String(describing: self.currentTopic)) ")
            //add post to topic's array
            self.currentTopic?.addPost(post: self.currentPost!)
            //encode the updated post array
            let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
            //find the topic in the database and update post array???
            self.db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1)
            
            //send current post to database
            let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
            self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
                error in
                if (error != nil) {
                    print("error writing post to firestore: \(String(describing: error))")
                    return
                } else {
                    print("success writing post to firestore")
                }
            }
            
            self.currentUser?.addCreatedPost(post: self.currentPost!)
            let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
            self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
            
            self.PostTitle.text = ""
            self.PostTopic.text = ""
            self.PostCaption.text = ""
            self.PostImage.image = nil
            self.performSegue(withIdentifier: "toTimeline", sender: self)
            return
        }
    }
    
    
    @IBAction func UploadImage(_ sender: Any) {
        //optional, user can attach an image to their post
        print("IN BUTTON UPLOAD IMAGE")
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        /*PostImage.image = self.image
        
        print("self.image is: \(String(describing: self.image))")
        self.uploadImg((self.image ?? self.defaultImage), completion: { (state, result) in
            if (!state) {
                self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                return
            } else {
                self.imgURL = result
                self.currentPost?.imgURL = result
                return
            }
        })
        
        return; */
    }
    
    func afterImagePicker () {
        PostImage.image = self.image
        print("self.image is: \(String(describing: self.image))")
        self.uploadImg((self.image ?? self.defaultImage), completion: { (state, result) in
            if (!state) {
                self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                return
            } else {
                self.imgURL = result
                self.currentPost?.imgURL = result
                return
            }
        })
        print("imgURL in after image picker: \(self.imgURL)")
    }
    
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("IN IMAGE PICKER CONTROLLER")
        var image: UIImage
          if let possibleImage = info[.editedImage] as? UIImage{
              image = possibleImage
          } else if let possibleImage = info[.originalImage] as? UIImage {
              image = possibleImage
          } else {
              return;
          }
          self.image = image
          self.PostImage.image = image
          self.imageExt = ".png"
          self.dismiss(animated: true, completion: afterImagePicker)
      }
    
    
    func uploadImg (_ image: UIImage, completion: @escaping (_ hasFinished: Bool,_ url: String) -> Void) {
        print("IN UPLOAD IMG")
        let data: Data = image.jpegData(compressionQuality: 1.0)!
        let ref = Storage.storage().reference(withPath: "media/" + (self.currentUser?.email)! + "/" +  (self.PostTitle.text)! + "/" +  "pic.jpeg")
        ref.putData(data, metadata: nil,
                    completion: { (meta, error) in
                        if error == nil {
                            //return url
                            ref.downloadURL(completion: { (url, error) in
                                if (error != nil) {
                                    print ("some error happened here \(error!.localizedDescription)")
                                    completion(false, "")
                                } else {
                                    self.imgURL = url!.absoluteString
                                    completion(true, url!.absoluteString)
                                }
                            })
                        }
        })
    }
    
    @IBAction func SubmitPost(_ sender: Any) {
        let postTitle = PostTitle.text ?? ""
        let postTopic = PostTopic.text ?? ""
        let postCaption = PostCaption.text ?? ""
        let postImage = PostImage.image ?? nil
        let followerArray = [User]()
        let comments = [String]()
        let numLikes: Int = 0
        //let defaultImage: String = ""
        
        //if a field is left blank
        if (postTitle == "" || postTopic == "" || postCaption == "") {
            let alertController = UIAlertController(title: "Error", message: "Please complete all fields before submitting post.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            self.PostTitle.text = ""
            self.PostTopic.text = ""
            self.PostCaption.text = ""
            self.PostImage.image = nil
            return;
        }
        
        if (postCaption.count > 500 || postTopic.contains(",")) {
            //caption has to be less than 500 chars and only one topic per post
            let alertController = UIAlertController(title: "Error", message: "Valid posts must be less than 500 characters and have only one topic.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            self.PostTitle.text = ""
            self.PostTopic.text = ""
            self.PostCaption.text = ""
            self.PostImage.image = nil
            return;
        }
        
        //create a post object, have to add it to user's created post array and topic's post array
        self.currentPost = Post.init(topic: postTopic, title: postTitle, caption: postCaption, creatorId: currentUser!.email, img: imgURL)
        
        //need to check if a topic exists in the database, if it does not, need to create a new topic
        db.collection("topics").whereField("title", isEqualTo: postTopic).getDocuments() { (QuerySnapshot, err) in
            if QuerySnapshot?.isEmpty == true {
                //topic does not exist, so create a new topic in database and topic object
                print("Topic does not exist")
                print("imgURL: \(self.imgURL)")
                //create a topic object and add current post to its post array
                self.currentTopic = Topic.init(title: postTopic)
                //add new post to the user's created post array
                self.currentTopic?.addPost(post: self.currentPost!)
                self.currentUser?.addCreatedPost(post: self.currentPost!)
                let dataToWrite = try! FirestoreEncoder().encode(self.currentUser)
                self.db.collection("users").document(self.currentUser!.email).setData(dataToWrite)
                
                let dataToWrite1 = try! FirestoreEncoder().encode(self.currentTopic)
                self.db.collection("topics").document(self.currentTopic!.title).setData(dataToWrite1) { error in
                    if (error != nil) {
                        print("error writing topic to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing topic to firestore")
                    }
                }
                
                let dataToWrite2 = try! FirestoreEncoder().encode(self.currentPost)
                self.db.collection("posts").document(self.currentPost!.postId).setData(dataToWrite2) {
                    error in
                    if (error != nil) {
                        print("error writing post to firestore: \(String(describing: error))")
                        return
                    } else {
                        print("success writing post ot firestore")
                    }
                }
                //create post with the new topics
                self.PostTitle.text = ""
                self.PostTopic.text = ""
                self.PostCaption.text = ""
                self.PostImage.image = nil
                self.performSegue(withIdentifier: "toTimeline", sender: self)
                return
                
            }
            else {
                //topic does exist, so add post to that topic's post array and add it to the database
                print("Topic does exist")
                //retrieve topic object and add current post to its post array
                DispatchQueue.main.async() {
                    Topic.getTopic(topicTitle: postTopic, completion: self.getTheTopic)
                }
                print("current topic in submit post: \(String(describing: self.currentTopic))")
                self.performSegue(withIdentifier: "toTimeline", sender: self)

                return
                
            }
            
        }
        
        
        
    }
    
    
    @IBAction func DeleteTest(_ sender: Any) {
        let exampleDelete = DeletePostViewController()
        exampleDelete.DeletePost(self)
    }
    
    
    
    
}
