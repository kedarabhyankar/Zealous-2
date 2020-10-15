//
//  AllTopicsViewController.swift
//  Zealous
//
//  Created by Vanshika Ramesh on 10/13/20.
//

import UIKit

class AllTopicsViewController: UIViewController {
    @IBOutlet weak var topicsTableView: UITableView!
    
    var currentUser: WriteableUser? = nil
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(currentUser: WriteableUser) {
        self.currentUser = currentUser
        // Similar function call : currentUser.getFollowedTopics(addTopic: addTopic)
        // Add function call to get list of all topics
    }
    
    
    func addTopic(topic: Topic) {
        topics.append(topic)
        topicsTableView.reloadData()
    }
}

extension AllTopicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? AllTopicsViewCell
        let topic = topics[indexPath.item]
        cell?.topic.text = topic.title
        return cell!
    }
}
