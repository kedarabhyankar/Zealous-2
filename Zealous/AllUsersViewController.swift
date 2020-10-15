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
        // Do any additional setup after loading the view.
        WriteableUser.getCurrentUser(completion: getUser)
    }
    

    func getUser(user: WriteableUser) {
        self.currentUser = user
        currentUser!.getAllUsers(allUsers: getUsers)
    }
    
    func getUsers(allUsers: [WriteableUser]) {
        self.allUsersArray = allUsers
        for aUser in allUsersArray {
            print("user: " + aUser.email + " " + aUser.firstName)
        }
    }
    
    
}
