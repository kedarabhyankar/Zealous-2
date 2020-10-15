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
    var users: [WriteableUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        // Similar function call : currentUser.getFollowers(addUser: addUser)
        // Add function call to get list of all users
    }
    
    func addUser(user: WriteableUser) {
        users.append(user)
        usersTableView.reloadData()
    }
}

extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? AllUsersViewCell
        let user = users[indexPath.item]
        cell?.username.text = user.username
        return cell!
    }
}
