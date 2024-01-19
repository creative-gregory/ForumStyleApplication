//
//  NewPostViewController.swift
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

enum PostState {
    case awaitingPost
    case posting
    case posted
    case failed
}

enum VerifyIDState {
    case idle
    case awaiting
    case exists
    case absent
}

class NewPostViewController: UIViewController {
    var ref:DatabaseReference = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var postContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postContent!.layer.borderWidth = 1
        postContent!.layer.borderColor = UIColor.systemPurple.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
    }
    
    func createPost(postContent: String) {
        let genID = generatePostID()
        
        FirebaseDatabaseService.shared.verifyPostID(id: genID) { verifyID in
            switch verifyID {
            case .exists:
                self.createPost(postContent: postContent)
        
            case .absent:
                FirebaseDatabaseService.shared.generatePost(id: genID, postContent: postContent) { state in
                    switch state {
                    case .awaiting:
                        self.activityIndicator.stopAnimating()
                        
                    case .loading:
                        self.activityIndicator.startAnimating()
                        
                    case .loaded:
                        self.activityIndicator.stopAnimating()
                        print("\(genID) Was Posted")
                        self.dismiss(animated: true)
                        
                    case .failed:
                        self.activityIndicator.stopAnimating()
                        let alert = displayAlert(title: "Error", message: "Issue Creating Post.")
                        self.present(alert, animated: true)
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func postButton(_ sender: Any) {
        guard let postContent = postContent.text, !postContent.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please Enter A Valid Post")
            self.present(alert, animated: true)
            
            return
        }
        
        self.createPost(postContent: postContent)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
}
