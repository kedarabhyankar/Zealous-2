//
//  AdminUsersViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 11/12/20.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import BRYXBanner
import CodableFirebase

class AdminUsersViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    var currentUser: WriteableUser? = nil
    var allUsersArray: [WriteableUser] = []
    var name:WriteableUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        WriteableUser.getAllUsersAdmin(allUsers:getUsers)
    }
    
    func getUsers(allUsers: [WriteableUser]) {
        self.allUsersArray = allUsers
        for i in 0..<allUsers.count {
            let aUser = allUsersArray[i]
            print("user: " + aUser.email + " " + aUser.firstName)
        }
        usersTableView.reloadData()
    }
}
    
    
extension AdminUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = allUsersArray[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? AdminUsersViewCell
        cell?.username.text = user.username
        let auth = Auth.auth()
        let userLog = auth.currentUser
        
        if (userLog?.email) == nil {
            cell?.delete.isHidden = true
        }
        else {
            cell?.delete.isHidden = false
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        print("topic: \(allUsersArray[indexPath.row].username)")
        name = allUsersArray[indexPath.row]
        self.performSegue(withIdentifier: "toProfile", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let viewController = segue.destination as! AdminProfileViewController
            viewController.user = name
        }
    }
}


