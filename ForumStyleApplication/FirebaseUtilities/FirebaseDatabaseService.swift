//
//  FirebaseDatabaseService.swift
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

class FirebaseDatabaseService {
    static let shared = FirebaseDatabaseService()
    private var ref: DatabaseReference = Database.database().reference()
    
    // Most of these functions operate using the Post's ID
    
    // Removes a post from the database
    func removePost(postID: String, state: @escaping (_ state: LoadingState) -> Void) {
        state(.awaiting)
        
        self.verifyPost(postID: postID) { verifyState in
            switch verifyState {
            case .present:
                self.ref.child("Posts").child(postID).removeValue { (error, ref) in
                    state(.loading)
                    
                    if error != nil {
                        if let error = error {
                            print("Failed to Delete Post: \(error.localizedDescription)")
                        }
                        
                        state(.failed("There was a problem deleting your post. Please try again."))
                    }
                    else {
                        print("Post Deleted with ID: \(postID) removed")
                        state(.loaded)
                    }
                }
                
            case .absent:
                state(.failed("There was a problem deleting your post. Please try again."))
                
            case .failed(let error):
                state(.failed(error))
            }
        }
        
    }
    
    // Retrieves all available post from the database
    // May refactor to query (n) posts at a time
    // ref.child("test").queryOrderedByKey().queryLimited(toLast: 10)
    func retrievePosts(state: @escaping (_ state: LoadingStateReturn) -> Void) {
        print("Retrieving Posts")
        state(.awaiting)
        
        DispatchQueue.main.async {
            state(.loading)
            
            self.ref.child("Posts").observeSingleEvent(of: .value, with: { (snapshot) in
                var posts = [Post]()
                
                if snapshot.exists() {
                    guard let postyArray = snapshot.value as? [String:[String:Any]] else { return }
                    
                    for (postID, postData) in postyArray {
                        var newPost: Post
                        
                        guard let uid = postData["uid"] as? String else { print("Error with uid"); return }
                        guard let username = postData["username"] as? String else { print("Error with username \(postID)"); return }
                        guard let content = postData["content"] as? String else { print("Error with content"); return }
                        guard let date = postData["date"] as? String else { print("Error with date"); return }
                        
                        if postData.keys.contains("likes") {
                            guard let likes = postData["likes"] as? [String:Any], !likes.isEmpty else { print("Error with likes"); return }
                            newPost = Post(id: postID, uid: uid, username: username, date: date, content: content, likes: likes)
                        }
                        else {
                            newPost = Post(id: postID, uid: uid, username: username, date: date, content: content, likes: [:])
                        }
                        
                        posts.append(newPost)
                    }
                    
                    posts.sort(by: { $0.date > $1.date })
                    state(.loaded(posts))
                }
                else {
                    print("No Posts Available")
                    let newPost = Post(id: "", uid: "", username: "", date: "", content: "No posts yet, be the first!")
                    posts.append(newPost)
                    
                    state(.loaded(posts))
                }
            })
        }
    }
    
    // Like Handler
    func likeHandler(postID: String, state: @escaping (_ state: LoadingState) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        state(.awaiting)
        
        DispatchQueue.main.async {
            self.verifyPost(postID: postID) { verifyState in
                switch verifyState {
                case .present:
                    self.ref.child("Posts").child(postID).child("likes").observeSingleEvent(of: .value) { (snapshot, error) in
                        state(.loading)
                        if snapshot.exists() {
                            // Case 1: More than one user has liked the post
                            // Action A: If the user already liked the post, remove it
                            // Action B: If the user has not liked the post, append it
                            guard let like = snapshot.value as? [String:Any] else { return }
                            
                            // Action A: The user has already like, Remove
                            if like.keys.contains(currentUser.uid) {
                                self.removeLike(postID: postID) { likeState in
                                    switch likeState {
                                    case true:
                                        print("\(currentUser.uid) has liked removed")
                                        state(.loaded)
                                    case false:
                                        print("Awaiting")
                                    }
                                }
                                
                                // Add exception handling for if the like cannot be removed, like a retry
                            }
                            else {
                                // Action B: The user has not like, Append
                                self.appendLike(postID: postID) { likeState in
                                    switch likeState {
                                    case true:
                                        print("\(currentUser.uid) has liked appended")
                                        state(.loaded)
                                    case false:
                                        print("Awaiting")
                                    }
                                }
                            }
                        }
                        
                        else {
                            // Case 2: No users have like the post and this will be the initial liker - Action Append New Like
                            self.appendLike(postID: postID) { likeState in
                                switch likeState {
                                case true:
                                    print("\(currentUser.uid) has liked appended")
                                    state(.loaded)
                                case false:
                                    print("Awaiting")
                                }
                            }
                        }
                    }
                    
                case .absent:
                    state(.failed("Post not longer exists."))
                    
                case .failed(let error):
                    state(.failed(error))
                }
            }
        }
    }
    
    // Appends like to database
    func appendLike(postID: String, appendState: @escaping (_ state: Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        appendState(false)
        
        let likeData = [
            "date": getDate(),
            "name": currentUser.displayName
        ]
        
        ref.child("Posts").child(postID).child("likes").child(currentUser.uid).setValue(likeData) { (error, ref) -> Void in
            if error != nil {
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            else {
                appendState(true)
            }
        }
    }

    // Removes like from database
    func removeLike(postID: String, removeState: @escaping (_ state: Bool) -> Void) {
        removeState(false)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        self.ref.child("Posts").child(postID).child("likes").child(currentUser.uid).removeValue() { (error, ref) -> Void in
            removeState(true)
        }
    }
    
//    func placeHolderFunction() {
//        self.verifyPost(postID: postID) { verifyState in
//            switch verifyState {
//            case .present:
//            case .absent:
//            case .failed(let error):
//            default:
//                break
//
//            }
//        }
//    }
    
    // Appends a new comment to the PostID supplied
    func postComment(postID: String, commentString: String, state: @escaping (_ state: LoadingState) -> Void) {
        let commentID = generatePostID()
        print(commentID)
        guard let currentUser = Auth.auth().currentUser else { return }
        state(.awaiting)
        
        self.verifyPost(postID: postID) { verifyPostID in
            switch verifyPostID {
            case .present:
                print("Processing Comment")
                
                self.verifyCommentID(postID: postID, commentID: commentID) { verifyCommentID in
                    switch verifyCommentID {
                    case .absent:
                        
                        let comment = [
                            "uid": currentUser.uid,
                            "name": currentUser.displayName,
                            "date": getDate(),
                            "comment": commentString
                        ]
                        
                        
                        self.ref.child("Posts").child(postID).child("comments").child(commentID).setValue(comment) { (error, ref) -> Void in
                            state(.loading)
                            
                            if error != nil {
                                if let error = error {
                                    print(error.localizedDescription)
                                    state(.failed("Issue Posting Comment"))
                                }
                            }
                            else {
                                state(.loaded)
                            }
                        }
                        
                    case .exists:
                        print("Comment ID Already Exists - Retry")
                    default:
                        break
                    }
                }
                
                
                
            case .absent:
                print("Post does not exist")
                state(.failed("Post no longer exists."))
                
            case .failed(let error):
                state(.failed(error))
            }
        }
        

    }
    
    // Verifies if a post is in the database for interactions
    func verifyPostID(id: String, verifyState: @escaping (_ postState: VerifyIDState) -> Void) {
        verifyState(.idle)
        
        self.ref.child("Posts").child(id).observeSingleEvent(of: .value) { (snapshot) in
            verifyState(.awaiting)
            
            if snapshot.exists() {
                print("Post ID Exists")
                verifyState(.exists)
            }
            else {
                print("Post ID Absent")
                verifyState(.absent)
            }
        }
    }
    
    // Verifies if a post is in the database for interactions
    func verifyCommentID(postID: String, commentID: String, verifyState: @escaping (_ done: VerifyIDState) -> Void) {
        verifyState(.idle)
        
        self.ref.child("Posts").child(postID).child("comments").child(commentID).observeSingleEvent(of: .value) { (snapshot) in
            verifyState(.awaiting)
            
            if snapshot.exists() {
                print("Post ID Exists")
                verifyState(.exists)
            }
            else {
                print("Post ID Absent")
                verifyState(.absent)
            }
        }
    }
    
    // Generates a new post and pushes to the database
    func generatePost(id: String, postContent: String, postState: @escaping (_ done: LoadingState) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        postState(.awaiting)
        
        let postData = [
            "content": postContent,
            "date": getDate(),
            "uid": currentUser.uid,
            "username": currentUser.displayName
        ]
        
        self.ref.child("Posts").child(id).setValue(postData) { (error, ref) -> Void in
            postState(.loading)
//        self.ref.child("Posts").childByAutoId().setValue(postData){ (error, ref) -> Void in
            if error != nil {
                if let error = error {
                    postState(.failed(error.localizedDescription))
                    print(error.localizedDescription)
                }
            }
            else {
                postState(.loaded)
            }
        }
    }
    
    // Monitors Likes on Post Details Page
    func monitorLikes(postID: String, state: @escaping (_ state: LoadingStateReturn) -> Void) {
        state(.awaiting)
        
        self.ref.child("Posts").child(postID).child("likes").observe(.value) { (snapshot) in
            state(.loading)
            
            if snapshot.exists() {
                guard let likeCollection = snapshot.value as? [String:[String:Any]] else { return }
                state(.loaded(likeCollection))
            }
            else {
//                print("No Likes")
                state(.loaded([:]))
            }
        }
    }
    
    // Monitors Comments on Post Details Page
    func monitorComments(postID: String, state: @escaping (_ state: LoadingStateReturn) -> Void) {
        state(.awaiting)
        
        self.ref.child("Posts").child(postID).child("comments").observe(.value) { (snapshot) in
            state(.loading)
            var commentArray = [Comment]()
            
            if snapshot.exists() {
                guard let commentCollection = snapshot.value as? [String:[String:Any]] else { return }
                
                for (commentKey, commentData) in commentCollection {
                    let id = commentKey
                    guard let uid = commentData["uid"] as? String else { return }
                    guard let name = commentData["name"] as? String else { return }
                    guard let date = commentData["date"] as? String else { return }
                    guard let comment = commentData["comment"] as? String else { return }
                    
                    let newComment = Comment(id: id, uid: uid, username: name, date: date, comment: comment)
                    commentArray.append(newComment)
                }
                
                commentArray.sort(by: {$0.date > $1.date })
                state(.loaded(commentArray))
            }
            else {
                print("No Comments Available")
              
                let emptyComment = Comment(id: "", uid: "", username: "", date: "", comment: "Be the first to leave a comment!")
                commentArray.append(emptyComment)
                
                state(.loaded(commentArray))
            }
        }
    }
    
    // Removes Post from database on Forum TableView Page
    func removeComment(postID: String, commentID: String, state: @escaping (_ state: LoadingState) -> Void) {
        state(.awaiting)
        
        self.ref.child("Posts").child(postID).child("comments").child(commentID).removeValue { (error, ref) in
            state(.loading)
            
            if error != nil {
                if let error = error {
                    print(error.localizedDescription)
                    state(.failed("Failed to delete post."))
                }
            }
            else {
                state(.loaded)
            }
        }
    }
    
    // Function to set user status as online
    func userIsOnline() {
        guard let currentUser = Auth.auth().currentUser else { return }
        self.ref.child("Users").child(currentUser.uid).setValue(currentUser.email)
    }
    
    // Sets Username in database to avoid duplicate usernames
    func setUsername(username: String, verifyName: @escaping (_ state: VerifyState) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let usernameData = [currentUser.uid: currentUser.email]
        
        self.ref.child("Users").child(username.lowercased()).setValue(usernameData) { (error, ref) in
            if error != nil {
                print("Failure: Username Not Set")
                verifyName(.failed("Failure: Username Not Set"))
            }
            else {
                print("Success: Username Set")
                verifyName(.present)
            }
        }
    }
    // Checks database for used usernames
    func isUsernameTaken(username: String, verifyName: @escaping (_ state: VerifyState) -> Void) {
        self.ref.child("Users").child(username.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print("Failure: Username Taken")
                verifyName(.present)
            }
            else {
                print("Success: Username Not Taken")
                verifyName(.absent)
            }
            
        })
//                                                                   withCancel: { (error) in
//            print(error.localizedDescription)
//            verifyName(.failed(error.localizedDescription))
//        }

    }
    
    // Verify if post is still in the database, cannot interact with posts that do not exist
    func verifyPost(postID: String, verifyState: @escaping (_ state: VerifyState) -> Void) {
        self.ref.child("Posts").child(postID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                log(message: "Post exists", errorFlag: false)
//                print("Post exists")
                verifyState(.present)
            }
            else {
//                print("Post does not exists")
                log(message: "Post does not exists.", errorFlag: true)
                verifyState(.failed("Post does not exists."))
            }
        }
    }
    
    // Just in case function to remove users when they exit the application i.e. Online/Offline Status
    func removeUser(userState: @escaping (_ state: UserState) -> Void) {
        userState(.awaiting)
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        self.ref.child("User").child(currentUser.uid).removeValue { (error, ref) in
            if error != nil {
                if let error = error {
                    userState(.failed(error.localizedDescription))
                    print("Failed to Delete User")
                }
            }
            else {
                print("User Removed")
                userState(.absent)
            }
        }
    }
    
}
