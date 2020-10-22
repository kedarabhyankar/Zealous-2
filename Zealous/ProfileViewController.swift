//
//  ProfileViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/12/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

class ProfileViewController: UIViewController {

    
    
    @IBOutlet weak var navigationBarPosts: UISegmentedControl!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var profileTableView: UITableView!
    var currentUser: WriteableUser? = nil
    var profilePosts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
        profileTableView.rowHeight = 540
        profileTableView.estimatedRowHeight = 540
        profileTableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        //profileTableView.delegate = self
        //profileTableView.dataSource = self
        print("IN LOAD LIST")
        self.performSegue(withIdentifier: "toProfile", sender: self)
        //WriteableUser.getCurrentUser(completion: getUser(currentUser:))
        //profileTableView.reloadData()
    }
    
    
    func getUser(currentUser: WriteableUser) {
        print("getUser")
        self.currentUser = currentUser
        bio.text = currentUser.bio
        username.text = currentUser.username
        name.text = currentUser.firstName + " " + currentUser.lastName
        let path = "media/" + (currentUser.email) + "/" +  "profile.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                self.profilePic.image = UIImage(data: data!)
            }
        }
        WriteableUser.getCreatedPosts(email: currentUser.email, completion: addPost)
        
        //currentUser.getProfilePosts(addPost: addPost) // populates the likedPosts array
        afterGettingCurrentUser()
        
    }
    
    func afterGettingCurrentUser() {
//        currentUser?.follow(email: "ramesh32@purdue.edu")
        print(currentUser?.followers ?? "")
    }
    
    
    func addPost(postArray: [Post]) {
        for post in postArray {
            profilePosts.append(post)
            profileTableView.reloadData()
        }
    }
    
    func addPostArray(post: Post){
        profilePosts.append(post)
        profileTableView.reloadData()
    }
    
    
    @IBAction func indexChanged() {
        switch navigationBarPosts.selectedSegmentIndex{
        case 0:
            //Primary Posts
            profilePosts.removeAll()
            WriteableUser.getCreatedPosts(email: (currentUser?.email)!, completion: addPost)
        case 1:
            //All Interactions
            profilePosts.removeAll()
            currentUser?.getLikedPosts(addPost: addPostArray)
            currentUser?.getDislikePosts(addPost: addPostArray)
        case 2:
            //Saved Posts
            print("SAVED POSTS")
            profilePosts.removeAll()
            currentUser?.getSavedPosts(addPost: addPostArray)
            print("saved printed")
            print(profilePosts.count)
        default:
            print("Default")
            profilePosts.removeAll()
            WriteableUser.getCreatedPosts(email: (currentUser?.email)!, completion: addPost)
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profilePosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        profilePosts.sort(by: { (first: Post, second: Post) -> Bool in
                   first.timestamp > second.timestamp
        })
        profilePosts = profilePosts.filter { post in
            return !post.madeAnonymously
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath) as! UserPostCell
        print(indexPath.row)
        for i in 0..<profilePosts.count {
            print("print")
            print(profilePosts[i].postId)
        }
        let post = profilePosts[indexPath.row]
        cell.username?.text = post.creatorId
        cell.postTitle?.text = post.title
        cell.postCaption?.text = post.caption
        cell.id = post.postId
        let path = "media/" + (post.creatorId) + "/" +  (post.title) + "/" +  "pic.jpeg"
        let ref = Storage.storage().reference(withPath: path)
        
        ref.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.postImage?.image = UIImage(data: data!)
            }
        }
        let ref2 = Storage.storage().reference(withPath: "media/" + post.creatorId + "/" + "profile.jpeg")
        ref2.getData(maxSize: 1024 * 1024 * 1024) { data, error in
            if error != nil {
                print("Error: Image could not download!")
            } else {
                cell.profilePicture?.image = UIImage(data: data!)
            }
        }
        return cell
    }
}
