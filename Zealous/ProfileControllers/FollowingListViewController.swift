//
//  FollowingListViewController.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/29/20.
//

import UIKit
import Firebase
import FirebaseFirestore

class FollowingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let currentUser = User.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingUsers", for: indexPath) as! FollowingCell
        cell.username.text = currentUser?.username
        return cell
    }
}
