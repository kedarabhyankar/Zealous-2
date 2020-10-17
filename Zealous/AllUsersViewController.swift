//
//  AllUsersViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit

class AllUsersViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var allUsersArray: [WriteableUser] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    
    func getUser(user: WriteableUser) {
        self.currentUser = user
        currentUser!.getAllUsers(allUsers: getUsers)
        usersTableView.reloadData()
    }
    
    func getUsers(allUsers: [WriteableUser]) {
        self.allUsersArray = allUsers
        for aUser in allUsersArray {
            print("user: " + aUser.email + " " + aUser.firstName)
        }
        usersTableView.reloadData()
    }
}
    
    
extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? AllUsersViewCell
        cell?.cellDelegate = self
        let user = allUsersArray[indexPath.item]
        cell?.username.text = user.username
        return cell!
    }
}
extension AllUsersViewController: AllUsersCellDelegate {
    func allusers(cell: AllUsersViewCell, didTappedThe button: UIButton?, emailId: String) {
        currentUser?.follow(email: emailId)
    }
    
}
