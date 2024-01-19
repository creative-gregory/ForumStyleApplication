//
//  LoginPageViewController.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/3/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class LoginPageViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var submitButtonOutlet: UIButton!
    @IBOutlet weak var createAccountButtonOutlet: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref:DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisses keyboard on tap outside of the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
//        NotificationCenter.default.addObserver(self, selector: #selector(logOut(notification:)), name: Notification.Name("LogOut"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(FirebaseDatabaseService.shared.logOutUser(logOutState:)), name: Notification.Name("LogOut"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
        
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
        
        isUserSignedIn { signInState in
            switch signInState {
            case .awaiting:
                self.hideUIElements(hideFlag: false)
                self.activityIndicator.stopAnimating()
                
            case .loading:
                self.hideUIElements(hideFlag: true)
                self.activityIndicator.startAnimating()
                
            case .loaded:
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "ForumPage", sender: self)
                
            default:
                break
            }
        }
    }
    
    func hideUIElements(hideFlag: Bool) {
        self.navigationController?.setNavigationBarHidden(hideFlag, animated: true)
        
        emailTextField.isHidden = hideFlag
        emailLabelOutlet.isHidden = hideFlag
        
        passwordTextField.isHidden = hideFlag
        passwordLabelOutlet.isHidden = hideFlag
        
        submitButtonOutlet.isHidden = hideFlag
        createAccountButtonOutlet.isHidden = hideFlag
    }
    
//    @objc func logOut(notification: Notification) {        
//        FirebaseDatabaseService.shared.logOutUser { state in
//            switch state {
//            case .awaiting:
//                print("Attempting Logout")
//                
//            case .loading:
//                print("Logging Out")
//                
//            case .loaded:
//                print("Current User Logged Out")
//                self.dismiss(animated: true)
//                
//            case .failed(let error):
//                print(error)
//                let alert = displayAlert(title: "Error", message: error)
//                self.present(alert, animated: true)
//            }
//        }
//    }
    
    @IBAction func submitLoginCreds(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please Enter a Valid Email")
            self.present(alert, animated: true)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please Enter A Valid Password")
            self.present(alert, animated: true)
            return
        }
        
        signUserIn(email: email, password: password) { signInState in
            switch signInState {
            case .loading:
                self.activityIndicator.startAnimating()
                
            case .loaded:
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "ForumPage", sender: self)
                
            case .failed(let signInError):
                self.activityIndicator.stopAnimating()
                let alert = displayAlert(title: "Error", message: "\(signInError)")
                self.present(alert, animated: true)
                
            default:
                break
            }
        }
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        self.performSegue(withIdentifier: "CreateAccount", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Dismisses keyboard when return in tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
