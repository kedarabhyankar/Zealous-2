//
//  FollowingViewController.swift
//  Zealous
//
//  Created by Grant Yolasan on 9/30/20.
//

import UIKit

class FollowingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let curr = WriteableUser.getCurrentUser()
        print(curr?.email)
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
