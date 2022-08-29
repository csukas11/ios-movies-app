//
//  AppDelegate.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window : UIWindow?
  
  func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    return true
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    if let tabBarController = window?.rootViewController as? UITabBarController {
//      if let navigationController = tabBarController.viewControllers?[0] as? UINavigationController {
//        if let viewController = navigationController.viewControllers[0] as? SearchViewController {
//          let networkProvider = NetworkManager()
//          viewController.setNetworkProvider(networkProvider)
//        }
//      }
//    }
      
    return true
  }

  // MARK: UISceneSession Lifecycle
  
  @available(iOS 13.0, *)
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  @available(iOS 13.0, *)
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}

