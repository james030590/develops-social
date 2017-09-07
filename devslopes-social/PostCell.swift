//
//  PostCell.swift
//  devslopes-social
//
//  Created by James McLean on 06/09/2017.
//  Copyright © 2017 James McLean. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    private var _post: Post!
    var likesRef: DatabaseReference!
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        _post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        caption.text = post.caption
        likesLbl.text = "\(post.likes)"
        
        if img != nil {
            //this means the post passed in has an image already downloaded in cache
            self.postImg.image = img
        } else {
            // no image in cach
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            //gets data from fireBase Storage, if completed succesfully stores image in data
            ref.getData(maxSize: 4 * 5000 * 5000, completion: { (data, error) in
                if error != nil {
                    print("JAMES: Unable to download image from FBase Storage")
                } else {
                    print("JAMES: Image successfully downloaded from FBase Storage")
                    if let imgData = data {
                        //if a UIImage can be succesfully created from the data then set the postCells post image to that image
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            // and save the image to the cache for future use
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        // likesRef contains a list of the current users likes, if the current user has liked the post that this PostCell is creating, it is
        // configured with a filled heart, if not an empty one
                likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self._post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self._post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    
    
    
    
    
    

}
