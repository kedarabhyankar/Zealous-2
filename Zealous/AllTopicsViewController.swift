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
    var name:Topic? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        WriteableUser.getCurrentUser(completion: getUser)
    }
    
    func getUser(user: WriteableUser) {
        self.currentUser = user
        currentUser!.getAllTopics(allTopics: getTopics)
        topicsTableView.reloadData()
        
    }
    
    func getTopics(allTopics: [Topic]) {
        self.allTopicsArray = allTopics
        for aTopic in allTopicsArray {
            print("topic: " + aTopic.id + " " + aTopic.title)
        }
        topicsTableView.reloadData()
    }
}
    

extension AllTopicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allTopicsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? AllTopicsViewCell
        cell?.cellDelegate = self
        let topic = allTopicsArray[indexPath.row]
        cell?.topic.text = topic.title
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
            let viewController = segue.destination as! PostsUnderTopicViewController
            viewController.topic = name
        }
    }
}
extension AllTopicsViewController: AllTopicsCellDelegate {
    func alltopics(cell: AllTopicsViewCell, didTappedThe button: UIButton?, topic:String) {
        currentUser?.followTopic(title: topic)
    }
}
