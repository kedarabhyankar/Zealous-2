//
//  SinglePostViewController.swift
//  Zealous
//
//  Created by Eric Hong on 11/18/20.
//

import UIKit
import BRYXBanner

class SinglePostViewController: UIViewController {

    override func viewDidLoad() {
        WriteableUser.getCurrentUser(completion: getUser)
        username.text=usernameText
        postCaption.text=postCaptionText
        postTitle.text = postTitleText
        DisplayedCommentUserName.text = DisplayedCommentUserNameText
        DisplayedCommentText.text=DisplayedCommentTextText
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var currentUser: WriteableUser? = nil
    var postID: String = ""
    var usernameText: String = ""
    var postCaptionText: String = ""
    var postTitleText: String = ""
    var DisplayedCommentUserNameText: String = ""
    var DisplayedCommentTextText: String = ""
    var commentsList: [String] = []
    @IBOutlet weak var savePost: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var upVote: UIButton!
    @IBOutlet weak var downVote: UIButton!
    @IBOutlet weak var DisplayedCommentUserName: UILabel!
    @IBOutlet weak var DisplayedCommentText: UILabel!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var postComment: UIButton!
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser  = currentUser         }
    
    
    @IBAction func upVotePressed(_ sender: Any) {
        currentUser?.addUpVote(postTitle: postID)
    }
    @IBAction func downVotePressed(_ sender: Any) {
        currentUser?.addDownVote(postTitle: postID)
    }
    @IBAction func postCommentPressed(_ sender: Any) {
        let alreadyLike = Banner(title: "Enter Text Into Comment", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
        alreadyLike.dismissesOnTap = true
        
        print("\(currentUser?.username ?? "username"): \(commentText.text! as String)")
        if ((commentText.text?.isEmpty) == true){
            self.showAndFocus(banner: alreadyLike)
            return
        }else{
        currentUser?.comment(comment: commentText.text! as String, postId: postID)
        commentText.text = ""
            //??????
//        if (currentUser?.username == self.username.text) {
//            cellDelegate?.profileCell(cell: self, didTappedThe: sender as? UIButton)
//        }
        }
        
    }
    func showAndFocus(banner : Banner){
        banner.show(duration: 3)
    }
    @IBAction func savePostPressed(_ sender: Any) {
        currentUser?.toggleSavedPost(postTitle: postID)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CommentsViewController
        {
            let vc = segue.destination as? CommentsViewController
            vc?.comments = commentsList
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
