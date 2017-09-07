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
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
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
    
    /////functions to conform to tableView Protocol/////////////////////////////////////////////////////////////////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {                                                                             //
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // the current post in the tableView, this is passed to the PostCell's configure cell method and                                   //
        // also used to check its imageUrl as a key for the imageCache
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            // imageCache contains NSStringKeys which are a posts imageUrl and its value is a UIImage of a downloaded image                //
            // if the image has already been downloaded and is in the cache, no need to download it again, set the img var                 //
            // tot the image that is contained in the cache
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                // configures the PostCell with an img already contained in cache
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                // configures the PostCell that doesnt have the img already stored in cache, so the img paramater defaults to nil          //
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }                                                                                                                                      //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////needed to conform to image picker protocol////////////////////////////////////////////////////////////////////////
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {     //
        
        //info is an array which contains the selected edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            //updates imageToAdd outlet in this VC and changes imageSelected to true
            imageToAdd.image = image
            imageSelected = true
        } else {
            print("JAMES: Valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }                                                                                                                       //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
/////////////////////////BUTTON PRESSES///////////////////////////////////////////////////////////////////
    @IBAction func postBtnPressed(_ sender: Any) {
        //guards to make sure when the post button is pressed, that there is an image selected and a caption is entered in the caption field
        guard let caption = captionField.text, caption != "" else {
            print("JAMES: A caption must be inserted before a post can be made")
            return
        }
        guard let img = imageToAdd.image, imageSelected == true else {
            print("JAMES: An image must be added for a post to be made")
            return
        }
        //creates a compressed jpeg from the user selected image
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            //creates a uniqueId for our jpeg and metadata
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //uploads our jpeg to storages post images folder with the key of the imgUid and value of the jpeg itself
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("JAMES: Unable to upload image to FBase Storage")
                } else {
                    print("JAMES: Successfully uploaded image to FBase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imageUrl: url)
                    }
                }
            })
        }
    }
    
    func postToFirebase(imageUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text!,
            "imageUrl": imageUrl,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageToAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
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
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
