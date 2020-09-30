//
//  VerifyEmailViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/28/20.
//

import UIKit
import FirebaseAuth
import BRYXBanner

class VerifyEmailViewController: UIViewController {
    
    var activityIndicator = UIActivityIndicatorView()
    var intermediaryUser = Profile(firstName: "", lastName: "", username: "", email: "")
    let invalidEmailBanner = Banner(title: "The email you entered was invalid.", subtitle: "Something seems to be wrong with the email address you entered...", image: nil, backgroundColor: UIColor.yellow, didTapBlock: nil)
    let unknownErrorBanner = Banner(title: "Something went wrong!", subtitle: "An unknown error occurred.", image: nil, backgroundColor: UIColor.red, didTapBlock: nil)
    let successBanner = Banner(title: "Successfully verified your email!", subtitle: "Thanks for verifying your email. Let's continue.", image: nil, backgroundColor: UIColor.green, didTapBlock: nil)
    let bannerDisplayTime = 3.0
    var didVerifyEmail = false
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        invalidEmailBanner.dismissesOnTap = true
        unknownErrorBanner.dismissesOnTap = true
        successBanner.dismissesOnTap = true
        Auth.auth().languageCode = "en"
        Auth.auth().currentUser?.sendEmailVerification(completion: {
            (error) in
            if(error != nil){
                let e = AuthErrorCode(rawValue: error!._code)
                switch(e){
                    case .invalidEmail:
                        self.invalidEmailBanner.show(duration: self.bannerDisplayTime)
                        break
                    default:
                        self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                        break
                }
                return
            }
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            (timer) in
            self.isEmailVerified()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        //delete user and perform segue back to the last screen
        //make sure to delete the user because if you don't the user will
        //still exist in the database even though the user stopped user
        //creation process
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDOB"){
            if let vc = segue.destination as? DOBViewController {
                vc.intermediaryUserOne = Profile(firstName: intermediaryUser.firstName, lastName: intermediaryUser.lastName, username: intermediaryUser.username, email: intermediaryUser.email)
            }
        }
    }
    
    func isEmailVerified(){
        Auth.auth().currentUser?.reload(completion: { (error) in
            if error != nil{
                self.unknownErrorBanner.show(duration: self.bannerDisplayTime)
                return
            } else {
                self.didVerifyEmail = Auth.auth().currentUser!.isEmailVerified
                if(self.didVerifyEmail){
                    self.successBanner.show(duration: self.bannerDisplayTime)
                    self.performSegue(withIdentifier: "toDOB", sender: self)
                }
            }
        })
        
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
