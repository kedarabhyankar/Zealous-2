//
//  CommentsViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/27/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CodableFirebase
import BRYXBanner

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentsTableView: UITableView!
    var currentUser: WriteableUser? = nil
    var likedPosts: [Post] = []
    var comments: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        print("getUser")
        self.currentUser = currentUser
        
        comments.append("vanshika: Nice Picture!")
        for comm in comments {
            print(comm)
        }
        commentsTableView.reloadData()
    }
    
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Comments", for: indexPath) as? CommentsTableViewCell
        let comment = comments[indexPath.item]
        cell?.username.text = comment
        return cell!
    }
}
