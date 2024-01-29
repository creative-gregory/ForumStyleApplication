//
//  ForumDetailsViewController.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/14/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class ForumDetailsViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var currentPost:Post!
    var comments = [Comment]()
    
    var likeCount = 0
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(cellNib, forCellReuseIdentifier: "CommentCell")

        nameLabel.text = currentPost.username
        contentTextView.text = currentPost.content
        
        FirebaseDatabaseService.shared.monitorComments(postID: currentPost.id) { state in
            switch state {
            case .awaiting:
                self.activityIndicator.stopAnimating()
                
            case .loading:
                self.activityIndicator.startAnimating()
                
            case .loaded(let commentArray):
                self.comments = commentArray as! [Comment]
                self.commentTableView.reloadData()
                self.activityIndicator.stopAnimating()
                
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
            }
        }
        
        FirebaseDatabaseService.shared.monitorLikes(postID: currentPost.id)  { state in
            switch state {
            case .loaded(let likeCollection):
                let likes = likeCollection as! [String:[String:Any]]
                
                switch likes.count {
                case 1:
                    self.likeLabel.text = "\(likes.count) Like"
                default:
                    self.likeLabel.text = "\(likes.count) Likes"
                }
                guard let currentUser = Auth.auth().currentUser else { return }
                
                if likes.keys.contains(currentUser.uid) {
                    self.likeButtonOutlet.setImage(UIImage(named: "like_favorite"), for: .normal)
                }
                else {
                    self.likeButtonOutlet.setImage(UIImage(named: "like_not_favorite"), for: .normal)
                }
            default:
                break
            }
        }
        
//        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func likeButton(_ sender: Any) {
        FirebaseDatabaseService.shared.likeHandler(postID: currentPost.id) {
            state in
            switch state {
            case .loaded:
                print("Like posted: \(self.currentPost.id)")
                
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
                
            default:
                break
            }
        }
    }
    
    @IBAction func submitComment(_ sender: Any) {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            let alert = displayAlert(title: "Error", message: "Please provide a valid comment")
            self.present(alert, animated: true)
            return
        }
        
        FirebaseDatabaseService.shared.postComment(postID: currentPost.id, commentString: comment) { commentState in
            switch commentState {
            case .loaded:
                self.commentTextField.text = nil
                
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
            default:
                break
            }
        }
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

extension ForumDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
        let currentComment = comments[indexPath.row]
        
        cell.delegate = self as CommentCellDelegate
        
        cell.nameLabel.text =  currentComment.username
        cell.commentLabel.text = currentComment.comment
        cell.dateLabel.text = convertToUserTimeZone(dateStr: currentComment.date)

        guard let currentUser = Auth.auth().currentUser else { return cell }
        
        if currentUser.uid == currentComment.uid {
            cell.deleteButtonOutlet.isHidden = false
        }
        else {
            cell.deleteButtonOutlet.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
     }
}

extension ForumDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ForumDetailsViewController: CommentCellDelegate {
    func deleteButton(cell: UITableViewCell) {
        guard let indexPath = self.commentTableView.indexPath(for: cell) else { return }
        let comment = self.comments[indexPath.row]
        
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you wish to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] action in FirebaseDatabaseService.shared.removeComment(postID: currentPost.id, commentID: comment.id) { state in
            switch state {
            case .loading:
                print("Deleting Comment with ID: \(comment.id)")
            case .loaded:
                print("Comment Deleted")
                self.commentTableView.reloadData()
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
            default:
                break
            }
        }
        }))
        
        self.present(alert, animated: true)
    }
}
