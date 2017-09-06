//
//  SignInVC.swift
//  devslopes-social
//
//  Created by James McLean on 05/09/2017.
//  Copyright © 2017 James McLean. All rights reserved.
//

import UIKit
//facebook imports
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("JAMES: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
///////////////////////Facebook button login//////////////////////////////////
    @IBAction func facebookBtnTapped(_ sender: RoundButton) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("JAMES: Unable to authenticate with facebook - \(error!)")
            } else if result?.isCancelled == true {
                print("JAMES: User cancelled Facebook Authentication")
            } else {
                print("JAMES: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    //////////////////////Firebase sign in with facebook credentials///////////////////////////////
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JAMES: Unable to authenticate with Firebase - \(error!)")
            } else {
                print("JAMES: Successfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)                }
            }
        }
    }
    
    /////////////////Firebase sign in or new user created with email and password////////////////////////////
    @IBAction func signInPressed(_ sender: Any) {
        
        if let email = emailField.text, let pwd = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("JAMES: Email User authenticated with firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("JAMES: Email User unable to authenticate with firebase")
                        } else {
                            print("JAMES: Email User successfully authenticated")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
        
    }
    
    func completeSignIn(id: String) {
        
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("JAMES: Data saved to keychain")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}

