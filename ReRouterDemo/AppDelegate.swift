//
//  AppDelegate.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit
import ReRouter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let router = NavigationRouter(AppCoordinator(), store: mainStore, { $0.path })

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        router.setupUpdate()
        return true
    }

}

