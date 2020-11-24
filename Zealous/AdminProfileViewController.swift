//
//  AdminProfileViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/15/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

class AdminProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    var user: WriteableUser? = nil
    var isBlocked: Bool = false
    var currentUser: WriteableUser? = nil
    var profilePosts: [Post] = []
    var isThisUser: Bool = true
    var firstCommentUN: String = ""
    var firstCommentText: String = ""
    var commentList: [String] = []
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var bio: UILabel!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.rowHeight = 620
        profileTableView.estimatedRowHeight = 620
        profileTableView.reloadData()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        getUser(currentUser: user!)
        isThisUser = false
        // Do any additional setup after loading the view.
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
}
    extension AdminProfileViewController: UITableViewDelegate, UITableViewDataSource {
        
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Profile", for: indexPath) as! AdminProfileViewCell
            print(indexPath.row)
            
            for i in 0..<profilePosts.count {
                print("print")
                print(profilePosts[i].postId)
            }
            let post = profilePosts[indexPath.row]
            commentList.removeAll()
            commentList = post.comments
            cell.username?.text = post.creatorId
            cell.postTitle?.text = post.title
            cell.postCaption?.text = post.caption
            cell.id = post.postId
            // COMMENTS
            if post.comments.isEmpty{
                firstCommentUN = ""
                firstCommentText = ""
            }else{
            let firstComment: String = post.comments[0]
                firstCommentUN = firstComment.components(separatedBy: ": ")[0]
                firstCommentText = firstComment.components(separatedBy: ": ")[1]
            }
            cell.DisplayedCommentUserName?.text = firstCommentUN
            cell.DisplayedCommentText?.text = firstCommentText
            //END COMMENTS
            
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
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if segue.destination is CommentsViewController
            {
                let vc = segue.destination as? CommentsViewController
                vc?.comments = commentList
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

