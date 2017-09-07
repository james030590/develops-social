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
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
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
    
    /////functions to conform to tableView Protocol/////////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // the current post in the tableView, this is passed to the PostCell's configure cell method and
        // also used to check its imageUrl as a key for the imageCache
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            // imageCache contains NSStringKeys which are a posts imageUrl and its value is a UIImage of a downloaded image
            // if the image has already been downloaded and is in the cache, no need to download it again, set the img var
            // tot the image that is contained in the cache
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                // configures the PostCell with an img already contained in cache
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                // configures the PostCell that doesnt have the img already stored in cache, so the img paramater defaults to nil
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////
    
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
