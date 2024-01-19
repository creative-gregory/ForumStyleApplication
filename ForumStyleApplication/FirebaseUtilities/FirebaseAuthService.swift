//
//  FirebaseAuthService.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/13/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

//class FirebaseAuthService {
//    static let shared = FirebaseAuthService()

    // Firebase Auth Logout Handler
    func logOutUser(logOutState: @escaping (_ state: LoadingState) -> Void) {
        logOutState(.awaiting)
        
        do {
            logOutState(.loading)
            try Auth.auth().signOut()

            logOutState(.loaded)
        }
        catch let signOutError as NSError {
            print("Error Signing Out: %@: ", signOutError)
            logOutState(.failed(signOutError.localizedDescription))
        }
    }
    
    // Firebase Auth Assign Username Handler
    func assignAuthUsername(name: String, state: @escaping (_ nameState: LoadingState) -> Void) {
        state(.awaiting)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = name
        
        changeRequest.commitChanges { (error) in
            if error != nil {
                if let error = error {
                    state(.failed(error.localizedDescription))
                }
            }
            else {
                if let displayName = currentUser.displayName {
                    print(displayName)
                    
                }
                state(.loaded)
                
            }
        }
    }
    
    // Firebase Auth Create Account Handler, could re-factor to remove some of the nesting aspects for the UI side
    func createUserAccount(email: String, password: String, name:String, state: @escaping (_ accountState: LoadingState) -> Void) {
        state(.awaiting)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            state(.loading)
            
            if error == nil {
                print("Account Creation Success")
                
                assignAuthUsername(name: name) { nameState in
                    switch nameState {
                    case .loading:
                        print("Assigning Name")
                        
                    case .loaded:
                        FirebaseDatabaseService.shared.setUsername(username: name) { setState in
                            switch setState {
                            case .present:
                                state(.loaded)
                            case .failed(let error):
                                print(error)
                            default:
                                break
                            }
                        }
                        
                    case .failed(let error):
                        print(error)
                        
                    default:
                        break
                    }
                }
            }
            
            else {
                if let error = error {
                    state(.failed(error.localizedDescription))
                    print(error.localizedDescription)
                }
            }
        }
    }

    // Firebase Auth Sign In Handler
    func signUserIn(email: String, password: String, state: @escaping (_ signInState: LoadingState) -> Void) {
        state(.loading)
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                if let user = Auth.auth().currentUser {
                    print("\(user.uid) Signed In")
                }
                
                state(.loaded)
            }
            else {
                if let error = error {
//                    guard let errorCode = AuthErrorCode(error.code) else { return }
                    state(.failed(error.localizedDescription))
                }
            }
        }
    }
    
    // Handles if a Firebase user is already in cache, will auto login if available
    func isUserSignedIn(state: @escaping (_ signInState: LoadingState) -> Void) {
        state(.loading)
        
        if Auth.auth().currentUser != nil {
            state(.loaded)
        }
        else {
            state(.awaiting)
        }
    }
    
    
    
//}



