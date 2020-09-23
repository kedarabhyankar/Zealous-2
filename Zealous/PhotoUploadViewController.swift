//
//  PhotoUploadViewController.swift
//  Zealous
//
//  Created by Kedar Abhyankar on 9/23/20.
//

import UIKit

class PhotoUploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imagePreview: UIImageView!
    var image: UIImage?
    var intermediaryProfileTwo: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onUploadImage(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
        imagePreview.image = self.image
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage
        if let possibleImage = info[.editedImage] as? UIImage{
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        } else {
            return;
        }
        
        self.image = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let intermediaryProfileThree = Profile(firstName: self.intermediaryProfileTwo.firstName, lastName: self.intermediaryProfileTwo.lastName, username: self.intermediaryProfileTwo.username, email: self.intermediaryProfileTwo.email, bio: "", dob: self.intermediaryProfileTwo.dateOfBirth, picture: self.image!)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "bioAndProfile") as! BioAndProfileViewController
        vc.finalProfile = intermediaryProfileThree
        self.present(vc, animated: true, completion: nil)
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
