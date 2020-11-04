//
//  SearchViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 11/4/20.
//

import UIKit
import Firebase
import FirebaseFirestore

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchControllerSearchBar: UISearchBar!
    
    @IBOutlet weak var searchUsersSwitch: UISwitch!
    @IBOutlet weak var searchPostsSwitch: UISwitch!
    @IBOutlet weak var executeSearchButton: UIButton!
    @IBOutlet weak var searchTable: UITableView!
    
    var db: Firestore
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
