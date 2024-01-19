//
//  Model.swift
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

enum LoadingState {
    case awaiting
    case loading
    case loaded
    case failed(String)
}

enum LoadingStateReturn {
    case awaiting
    case loading
    case loaded(Any)
    case failed(String)
}

enum VerifyState {
    case absent
    case present
    case failed(String)
}

enum UserState {
    case awaiting
    case absent
    case present
    case failed(String)
}

struct Post {
    var id: String
    var uid: String
    var username: String
    var date: String
    var content: String
    var likes: [String: Any]?
    var comments: [String: Any]?
}

struct Like {
    var uid: String
    var username: String
    var date: String
}

struct Comment {
    var id: String
    var uid: String
    var username: String
    var date: String
    var comment: String
}

// Test Source Control

