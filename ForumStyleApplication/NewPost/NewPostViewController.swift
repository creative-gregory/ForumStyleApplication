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

class NewPostViewController: UIViewController, UITextViewDelegate {
    var ref:DatabaseReference = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    var characterCount = 0
    let placeholder = "What's happening?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postContent.delegate = self
//        self.postContent.becomeFirstResponder()
        
        self.textViewDidChange(postContent)
        print(characterCount)
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
    }
    
    func createPost(postContent: String) {
        let postID = generatePostID()
        
        FirebaseDatabaseService.shared.verifyPostID(id: postID) { verifyID in
            switch verifyID {
            case .exists:
                self.createPost(postContent: postContent)
        
            case .absent:
                FirebaseDatabaseService.shared.generatePost(id: postID, postContent: postContent) { state in
                    switch state {
                    case .awaiting:
                        self.activityIndicator.stopAnimating()
                        
                    case .loading:
                        self.activityIndicator.startAnimating()
                        
                    case .loaded:
                        self.activityIndicator.stopAnimating()
                        print("\(postID) Was Posted")
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
    
    func textViewDidChange(_ textView: UITextView) {
//        self.characterCount = textView.text.count
        
        switch textView.text.count {
        case 0..<25:
            characterCountLabel.textColor = UIColor.green
            characterCountLabel.text = "\(textView.text.count)"
        case 25..<90:
            characterCountLabel.textColor = UIColor.orange
            characterCountLabel.text = "\(textView.text.count)"
        case 100..<Int.max:
            characterCountLabel.textColor = UIColor.red
            characterCountLabel.text = "\(textView.text.count)"
        default:
            break
        }
        
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.systemGray
        }
        else if textView.text != placeholder {
            textView.textColor = UIColor.label
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           // Called when you're trying to enter a character (to replace the placeholder)
           if textView.text == placeholder {
               textView.text = ""
           }
        
           return true
       }
    
}




