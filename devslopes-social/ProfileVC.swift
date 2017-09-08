//
//  ProfileVC.swift
//  devslopes-social
//
//  Created by James McLean on 08/09/2017.
//  Copyright © 2017 James McLean. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var userNameLbl: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameLbl.delegate = self
        
        //needed for choosing images with image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true  // allows editing before picking picture from camera roll
        imagePicker.delegate = self
        ///////////////////////////////////////////
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////BUTTON PRESSES BELOW///////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    
////////// presents the image picker to pic a profile photo////////////////
    @IBAction func profilePicBtnPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    ///////back to the feed if the done button is pressed
    @IBAction func doneBtnPressed(_ sender: Any) {
        
        guard let username = self.userNameLbl.text, username != "" else {
            print("JAMES: PROFILE: No user name entered")
            return
        }
        
        guard let img = self.profilePicButton.backgroundImage(for: UIControlState()), imageSelected == true else {
            print("JAMES: An image must be added for a post to be made")
            return
        }
        
        //creates a compressed jpeg from the user selected image
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            // metadata contains the download url
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //uploads our jpeg to storages profile-pics folder with the key of the users UID and value of the jpeg itself
            DataService.ds.REF_PROFILE_IMAGES.child(DataService.ds.REF_USER_CURRENT.key).putData(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("JAMES: PROFILE: Unable to upload profile image to FBase Storage")
                } else {
                    print("JAMES: PROFILE: Successfully uploaded profile image to FBase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        DataService.ds.REF_USERS.child("profile-pic-url").setValue(url)

                    }
                }
            })
        }
        performSegue(withIdentifier: "toFeed", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedVC = segue.destination as? FeedVC {
            feedVC.tempImage = self.profilePicButton.backgroundImage(for: UIControlState())!
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    /////////////////////DELEGATE FUNCTIONS BELOW////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    
    ////////needed to conform to image picker protocol////////////////////////////////////////////////////////////////////////
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {     //
        
        //info is an array which contains the selected edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            //updates imageToAdd outlet in this VC and changes imageSelected to true
            profilePicButton.setBackgroundImage(image, for: UIControlState())
            imageSelected = true
        } else {
            print("JAMES: PROFILE VC: Valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }                                                                                                                       //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    /////////hides keyboard if return is pressed///////////////
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    
}
