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
        for i in 0..<allUsers.count-1 {
            let aUser = allUsersArray[i]
            print("user: " + aUser.email + " " + aUser.firstName)
            if currentUser!.blockedBy.contains(aUser.email) {
                allUsersArray.remove(at: i)
            }
        }
        usersTableView.reloadData()
    }
}
    
    
extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = allUsersArray[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? AllUsersViewCell
        cell?.cellDelegate = self
        cell?.username.text = user.username
        if (self.currentUser!.blockedBy.contains(user.username)) {
            cell?.username.text = "user has blocked you"
            cell?.follow.isHidden = true
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let customViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        let user = allUsersArray[indexPath.item]
        if (self.currentUser!.blockedBy.contains(user.username)) {
            print("unable to display profile because user has blocked you")
            return
        }
        customViewController.currentUser = user
        customViewController.loggedInUser = currentUser!
        self.present(customViewController, animated: true, completion: nil)
    }
}
extension AllUsersViewController: AllUsersCellDelegate {
    func allusers(cell: AllUsersViewCell, didTappedThe button: UIButton?, emailId: String) {
        currentUser?.follow(email: emailId)
    }
    
}
