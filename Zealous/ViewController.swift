//
//  ViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/21/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
}

