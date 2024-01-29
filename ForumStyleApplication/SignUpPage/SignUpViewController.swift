//
//  SignUpViewController.swift
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

class SignUpViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var submitOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please Enter a Valid Email.")
            self.present(alert, animated: true)
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty, name.count <= 16 else {
            let alert = displayAlert(title: "Error", message: "Please Enter a Valid Name.")
            self.present(alert, animated: true)
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please Enter a Valid Password.")
            self.present(alert, animated: true)
            return
        }
        
        FirebaseDatabaseService.shared.isUsernameTaken(username: name) { state in
            switch state {
            case .absent:                
                createUserAccount(email: email, password: password, name: name) { accountState in
                    switch accountState {
                    case .awaiting:
                        self.hideUIElements(hideFlag: false)
                        self.activityIndicator.stopAnimating()
                        
                    case .loading:
                        self.hideUIElements(hideFlag: true)
                        self.activityIndicator.startAnimating()
                        
                    case .loaded:
                        self.activityIndicator.stopAnimating()
                        print("LOGIN HERE")
                        
                        signUserIn(email: email, password: password) { state in
                            switch state{
                            case .loading:
                                self.activityIndicator.startAnimating()
                                
                            case .loaded:
                                self.activityIndicator.stopAnimating()
                                self.performSegue(withIdentifier: "SignUpToForum", sender: self)
                                
                            case .failed(let signInError):
                                self.activityIndicator.stopAnimating()
                                
                                let alert = displayAlert(title: "Error", message: "\(signInError)")
                                self.present(alert, animated: true)
                                
                            default:
                                break
                            }
                        }
                        
                    case .failed(let error):
                        self.hideUIElements(hideFlag: false)
                        self.activityIndicator.stopAnimating()
                        
                        let alert = displayAlert(title: "Error", message: error)
                        self.present(alert, animated: true)
                    }
                }
                
//                FirebaseAuthService.shared.createUserAccountHandler(email: email, password: password, name: name) { accountState in
//                    switch accountState {
//                    case .awaiting:
//                        self.activityIndicator.stopAnimating()
//                        
//                    case .loading:
//                        self.activityIndicator.startAnimating()
//                        
//                    case .loaded:
//                        self.activityIndicator.stopAnimating()
//                        self.performSegue(withIdentifier: "SignUpToForum", sender: self)
//                        
//                    case .failed(let error):
//                        self.hideUIElements(hideFlag: false)
//                        self.activityIndicator.stopAnimating()
//
//                        let alert = displayAlert(title: "Error", message: error)
//                        self.present(alert, animated: true)
//                    }
//                }
                
            case .present:
                let alert = displayAlert(title: "Attention", message: "Username is already is use.")
                self.present(alert, animated: true)
                
            case .failed(let error):
                print(error)
            }
        }
        
        
    }
        
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideUIElements(hideFlag: Bool) {
        self.submitOutlet.isHidden = hideFlag
        self.cancelOutlet.isHidden = hideFlag
    }
}
