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
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    
    @IBOutlet weak var pwdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("VINCE: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
                if (result?.grantedPermissions.contains("email"))! {
                    if let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email"]) {
                        graphRequest.start(completionHandler: { (connection, result, error) in
                            if error != nil {
                                print(error!)
                            } else {
                                if let userEmail = result as? [String: String] {
                                    let fb_email: String = userEmail["email"]!
                                    self.firebaseAuth(credential: credential, username: self.getUsername(email: fb_email))
                                }
                            }
                        })
                    }
                }
            }
        }
        
    }
    
    func firebaseAuth(credential: FIRAuthCredential, username: String) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("VINCE: Unable to authenticate with Firebase - \(error)")
            } else {
                print("VINCE: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider, "username": username]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: {(user, error) in
                if error == nil {
                    print("VINCE: User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID, "username": self.getUsername(email: email)]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: {(user, error) in
                        if error != nil {
                            print("VINCE: Unable to authenticate with Firebase using email")
                        } else {
                            print("VINCE: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID, "username": self.getUsername(email: email)]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult =  KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("VINCE: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    func getUsername(email: String) -> String {
        let rangeOfAt: Range<String.Index> = email.range(of: "@")!
        let indexOfAt: Int = email.distance(from: email.startIndex, to: rangeOfAt.lowerBound)
        return email.substring(to: email.index(email.startIndex, offsetBy: indexOfAt))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

