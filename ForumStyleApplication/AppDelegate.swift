//
//  AppDelegate.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/12/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
//    var ref:DatabaseReference = Database.database().reference()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
//        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable") // remove once done
        
//        isUserSignedIn { signInState in
//            switch signInState {
//            case .loaded:
//                self.window = UIWindow(frame: UIScreen.main.bounds)
//
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginSignupVC")
//
//                self.window?.rootViewController = initialViewController
//                self.window?.makeKeyAndVisible()
//            default:
//                
//            }
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

//    func applicationWillTerminate(_ application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        guard let currentUser = Auth.auth().currentUser else { return }
//        self.ref.child("User").child(currentUser.uid).removeValue()
//    }

}

