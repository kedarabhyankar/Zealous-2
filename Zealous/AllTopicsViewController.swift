//
//  AllTopicsViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit

class AllTopicsViewController: UIViewController {
    @IBOutlet weak var topicsTableView: UITableView!
    
    var allTopicsArray: [Topic] = []
    var currentUser: WriteableUser? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /* testing print all topics in database */
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(user: WriteableUser) {
        self.currentUser = user
        currentUser!.getAllTopics(allTopics: getTopics)
        
    }
    
    func getTopics(allTopics: [Topic]) {
        self.allTopicsArray = allTopics
        for aTopic in allTopicsArray {
            print("topic: " + aTopic.id + " " + aTopic.title)
        }
    }
    
    

}
