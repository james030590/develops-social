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

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JAMES: Unable to authenticate with Firebase - \(error!)")
            } else {
                print("JAMES: Successfully authenticated with Firebase")
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        
        if let email = emailField.text, let pwd = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("JAMES: Email User authenticated with firebase")
                } else {
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("JAMES: Email User unable to authenticate with firebase")
                        } else {
                            print("JAMES: Email User successfully authenticated")
                        }
                    })
                }
            })
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}

