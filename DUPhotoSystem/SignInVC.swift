//
//  ViewController.swift
//  DUPhotoSystem
//
//  Created by lcocox on 2016/10/17.
//  Copyright © 2016年 lcocox. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("VINCE: Unable to authenricate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("VINCE: User cancelled Facebook authentication")
            } else {
                print("VINCE: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("VINCE: Unable to authenticate with Firebase - \(error)")
            } else {
                print("VINCE: Successfully authenticated with Firebase")
            }
        })
    }

}

