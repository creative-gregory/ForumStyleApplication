//
//  ForumTableViewController.swift
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

class ForumTableViewController: UITableViewController {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var postToSend:Post!
    var currentUser:User!
    private lazy var posts = [Post]()
    
    @IBOutlet weak var sortPostsButton: UIBarButtonItem!
    
    func sortHandler() {
        
        let menuHandler: UIActionHandler = { action in
            print(action.title)
        }
        
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Most Popular", comment: ""), image: UIImage(systemName: "viewfinder"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Newest to Oldest", comment: ""), image: UIImage(systemName: "books.vertical"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Oldest to Newest", comment: ""), image: UIImage(systemName: "bell"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Alphabetical", comment: ""), image: UIImage(systemName: "trash"), handler: menuHandler)
        ])
        
        let  btn = UIBarButtonItem(title: "Sort By", style: .plain, target: self, action: nil)
        
        //        navigationItem.leftBarButtonItem?.menu = barButtonMenu
        
        navigationItem.leftBarButtonItems?[1] = (btn)
        //        sortPostsButton.showsMenuAsPrimaryAction = true
        //        btn.menu = barButtonMenu
        // or using the initializer
        navigationItem.leftBarButtonItems?.append(UIBarButtonItem(title: "Manage", image: nil, primaryAction: nil, menu: barButtonMenu))
    }
    
    @IBAction func refreshControl(_ sender: UIRefreshControl) {
        FirebaseDatabaseService.shared.retrievePosts { state in
            switch state {
            case .awaiting:
                self.activityIndicator.stopAnimating()
                
            case .loading:
                self.activityIndicator.startAnimating()
                
            case .loaded(let posts):
                self.activityIndicator.stopAnimating()
                sender.endRefreshing()
                self.posts = posts as! [Post]
                self.tableView.reloadData()
                
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Getting New Posts...")
        //        sortHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let cellNib = UINib(nibName: "ForumsViewTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ForumsPage")
        
        initActivityMonitor(activityIndicator: activityIndicator, view: self.view)
        
        
        FirebaseDatabaseService.shared.retrievePosts { state in
            switch state {
            case .awaiting:
                self.activityIndicator.stopAnimating()
                
            case .loading:
                self.activityIndicator.startAnimating()
                
            case .loaded(let posts):
                self.activityIndicator.stopAnimating()
                self.posts = posts as! [Post]
                self.tableView.reloadData()
                
            default:
                break
            }
        }
        
        
        
        
    }
    
    @IBAction func newPostButton(_ sender: Any) {
        self.performSegue(withIdentifier: "NewPost", sender: self)
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        //        NotificationCenter.default.post(name: Notification.Name("LogOut"), object: nil)
        logOutUser { state in
            switch state {
            case .awaiting:
                print("Attempting Logout")
                
            case .loading:
                print("Logging Out")
                
            case .loaded:
                print("Current User Logged Out")
                self.dismiss(animated: true)
                
            case .failed(let error):
                print(error)
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumsPage", for: indexPath) as! ForumsViewTableViewCell
        let currentPost = posts[indexPath.row]
        
        cell.delegate = self as PostCellDelegate
        
        cell.nameLabel.text = currentPost.username
        cell.contentLabel.text = currentPost.content
        
        guard let currentUser = Auth.auth().currentUser else { return cell }
        
        if currentPost.uid == currentUser.uid {
            cell.deleteButtonOutlet.isHidden = false
        }
        else {
            cell.deleteButtonOutlet.isHidden = true
        }
        
        if let likeData = currentPost.likes {
            let likeCount = likeData.keys.count
            
            switch likeCount {
            case 1:
                cell.likeLabel.text = "\(likeData.keys.count) Like"
            default:
                cell.likeLabel.text = "\(likeData.keys.count) Likes"
            }
            
            if likeData.keys.contains(currentUser.uid) {
                cell.likeButtonOutlet.setImage(UIImage(named: "like_favorite"), for: .normal)
            }
            else {
                cell.likeButtonOutlet.setImage(UIImage(named: "like_not_favorite"), for: .normal)
            }
        }
        else {
            cell.likeLabel.text = "0 Likes"
            cell.likeButtonOutlet.setImage(UIImage(named: "like_not_favorite"), for: .normal)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postToSend = posts[indexPath.row]
        
        FirebaseDatabaseService.shared.verifyPost(postID: postToSend.id) { verifyState in
            switch verifyState {
            case .present:
                self.performSegue(withIdentifier: "PostView", sender: self)
                //                        tableView.deselectRow(at: indexPath, animated: true)
                
            case .absent:
                print("Post does not exist")
                
                let alert = displayAlert(title: "Error", message: "Post does not exist, please refresh your feed.")
                self.present(alert, animated: true, completion: nil)
                
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        return CGFloat(Double(posts[indexPath.row].content.count) * 0.5)
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostView" {
            let dataToSend = segue.destination as! ForumDetailsViewController
            
            dataToSend.currentPost = postToSend
        }
    }
    
    func reloadTable() {
        FirebaseDatabaseService.shared.retrievePosts { state in
            switch state {
            case .awaiting:
                print("Awaiting Posts")
            case .loading:
                print("Loading Posts")
            case .loaded(let posts):
                self.activityIndicator.stopAnimating()
                self.posts = posts as! [Post]
                self.tableView.reloadData()
            default:
                break
            }
        }
    }
}

extension ForumTableViewController: PostCellDelegate {
    func deleteButton(cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you wish to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in FirebaseDatabaseService.shared.removePost(postID: post.id) {
            state in
            switch state {
            case .awaiting:
                print("pending delete")
            case .loading:
                print("deleting")
            case .loaded:
                self.reloadTable()
                print("post deleted")
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error)
                self.present(alert, animated: true)
            }
        } }))
        
        self.present(alert, animated: true)
    }
    
    func likePost(cell: UITableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        
        FirebaseDatabaseService.shared.likeHandler(postID: post.id) {
            state in
            switch state {
                //            case .awaiting:
                //                print("awaiting")
                //            case .loading:
                //                print("loading")
            case .loaded:
                self.handleLocalLikes(index: indexPath.row)
                self.tableView.reloadData()
                
            case .failed(let error):
                let alert = displayAlert(title: "Error", message: error + "Please refresh your feed.")
                self.present(alert, animated: true)
                
            default:
                break
            }
        }
    }
    
    func handleLocalLikes(index: Int) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if ((self.posts[index].likes!.keys.contains(currentUser.uid))) {
            // Like is in the dict, need to remove
            self.posts[index].likes![currentUser.uid] = nil
        }
        else {
            // Like not in th dict, need to add
            let liker = [
                "date": getDate(),
                "name": currentUser.displayName
            ]
            
            self.posts[index].likes![currentUser.uid] = liker
        }
        
        //        print(self.posts[indexPath.row])
    }
    
    
    
}
