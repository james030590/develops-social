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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        
        KeychainWrapper.standard.remove(key: KEY_UID)
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToLogin", sender: nil)
    }
}
