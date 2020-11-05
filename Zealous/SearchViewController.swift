//
//  SearchViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 11/4/20.
//

import UIKit
import Firebase
import CodableFirebase

class SearchViewController: UIViewController, UITableViewDataSource,
                            UITableViewDelegate {
    
    @IBOutlet weak var searchControllerSearchBar: UISearchBar!
    @IBOutlet weak var searchUsersSwitch: UISwitch!
    @IBOutlet weak var searchPostsSwitch: UISwitch!
    @IBOutlet weak var executeSearchButton: UIButton!
    @IBOutlet weak var searchTable: UITableView!
    
    let db = Firestore.firestore();
    var userQueries = [WriteableUser]()
    var postQueries = [Post]()
    var userCounter = [Int]()
    var postCounter = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTable.delegate = self
        searchTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let postSearch = searchPostsSwitch.isOn;
        let userSearch = searchUsersSwitch.isOn;
        let searchToken = searchControllerSearchBar.text
        
        if((searchToken?.isEmpty) != nil){
            let alert = UIAlertController(title: "Invalid Search!",
                                          message:"You have to have soemthing to search!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true);
            return;
        }
        
        let query = [searchToken]
        
        if(userSearch){
            //if search
            db.collection("users").whereField("firstName", arrayContains: query).getDocuments() { (query, err) in
                if let err = err {
                    print("Error getting documents with specific error \(err)")
                    return;
                } else {
                    let docs = query?.documents
                    var i = 1;
                    for d in docs! {
                        let user = try! FirestoreDecoder().decode(WriteableUser.self, from: d.data())
                        self.userQueries.append(user)
                        self.userCounter.append(i)
                        i += 1;
                    }
                }
            }
            
            
            db.collection("users").whereField("lastName", arrayContains: query).getDocuments() { (query, err) in
                if let err = err {
                    print("Error getting documents with specific error \(err)")
                    return;
                } else {
                    let docs = query?.documents
                    var i = 0;
                    for d in docs! {
                        let user = try! FirestoreDecoder().decode(WriteableUser.self, from: d.data())
                        self.userQueries.append(user)
                        self.userCounter.append(i)
                        i += 1;
                    }
                }
            }
        }
        
        if(postSearch){
            db.collection("posts").whereField("caption", arrayContains: query).getDocuments() { (query, err) in
                if let err = err {
                    print("Error gettind documents with specific error \(err)");
                    return;
                } else {
                    let docs = query?.documents
                    var i = 0;
                    for d in docs! {
                        let post = try! FirestoreDecoder().decode(Post.self, from: d.data())
                        self.postQueries.append(post)
                        self.postCounter.append(i);
                        i += 1;
                    }
                }
            }
        }
        
        searchTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postQueries.count + userQueries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTable.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        var postOrUserFlag = 0; //1 for user, 2 for post
        for i in userCounter{
            if(i == indexPath.row){
                postOrUserFlag = 1;
                break;
            }
        }
        
        for i in postCounter{
            if (i == indexPath.row){
                postOrUserFlag = 2;
                break;
            }
        }
        
        if(postOrUserFlag == 1){
            cell.searchUsernameLabel.text = userQueries[indexPath.row].username
            cell.searchTextLabel.text = userQueries[indexPath.row].bio
        } else if(postOrUserFlag == 2){
            cell.searchUsernameLabel.text = postQueries[indexPath.row].title
            cell.searchTextLabel.text = postQueries[indexPath.row].caption
        }
        
        return cell;
    }
    
    
}


