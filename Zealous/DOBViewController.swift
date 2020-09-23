//
//  DOBViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit

class DOBViewController: UIViewController {
    
    var intermediaryUserOne: Profile!
    @IBOutlet weak var dobPicker: UIDatePicker!
    var minimumDateOfBirth: Date?
    var dateComponents: DateComponents
    var userDOB: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cal = Calendar.current
        dateComponents.year = 2007
        dateComponents.month = 1
        dateComponents.day = 1
        minimumDateOfBirth = cal.date(from: dateComponents)
        dobPicker.minimumDate = minimumDateOfBirth
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        userDOB = dobPicker.date
        let intermediaryUserTwo = Profile(firstName: intermediaryUserOne.firstName, lastName: intermediaryUserOne.lastName, username: intermediaryUserOne.username, email: intermediaryUserOne.email, dob: userDOB ?? Date.distantPast, bio: "")
        
    }
    
    @IBAction func onBack(_ sender: Any) {
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
