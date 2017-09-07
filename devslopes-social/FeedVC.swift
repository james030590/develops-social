//
//  FeedVC.swift
//  devslopes-social
//
//  Created by James McLean on 06/09/2017.
//  Copyright © 2017 James McLean. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageToAdd: CircleView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //needed for choosing images with image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true  // allows editing before picking picture from camera roll
        imagePicker.delegate = self
        ///////////////////////////////////////////
        
        //observes any changes to posts in the FBase Database and saves it in snapshot
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    //each snap from the snapshot is a post containing a caption, imageUrl and likes
                    print("SNAP: \(snap)")
                    //postDict = the contents of the post as a Dictionary of <String, Any>, which is passed to the Post class as a parameter on init
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        //snaps .key is a unique postID and its .value is the contents of the post as an Dictionary of <String, Any>
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        // the created post is appended to the posts array
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            cell.configureCell(post: post)
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    ////////needed to conform to image picker protocol//////////////////
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //info is an array which contains the selected edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            //updates imageToAdd outlet in this VC
            imageToAdd.image = image
        } else {
            print("JAMES: Valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func signOutPressed(_ sender: Any) {
        // the signout button removes the Key from the KeyChain Wrapper so that auto sign in isnt allowed
        KeychainWrapper.standard.remove(key: KEY_UID)
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToLogin", sender: nil)
    }
    
    //presents the image picker if button is tapped
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
}
