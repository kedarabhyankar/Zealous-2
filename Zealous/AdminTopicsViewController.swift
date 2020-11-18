//
//  AdminTopicsViewController.swift
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

class AdminTopicsViewController: UIViewController {
    
    @IBOutlet weak var topicsTableView: UITableView!
    
    var allTopicsArray: [Topic] = []
    var currentUser: WriteableUser? = nil
    var name:Topic? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        WriteableUser.getAllTopicsAdmin(allTopics: getTopics)
    }
    
    
    func getTopics(allTopics: [Topic]) {
        self.allTopicsArray = allTopics
        for aTopic in allTopicsArray {
            print("topic: " + aTopic.id + " " + aTopic.title)
        }
        topicsTableView.reloadData()
    }
}
    

extension AdminTopicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allTopicsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? AdminTopicsViewCell
        //cell?.cellDelegate = self
        let topic = allTopicsArray[indexPath.row]
        cell?.topic.text = topic.title
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
        print("topic: \(allTopicsArray[indexPath.row].title)")
        name = allTopicsArray[indexPath.row]
        self.performSegue(withIdentifier: "toPosts", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPosts" {
            let viewController = segue.destination as! AdminPostsViewController
            viewController.topic = name
        }
    }
}
