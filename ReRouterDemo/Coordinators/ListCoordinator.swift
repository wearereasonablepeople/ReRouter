//
//  ListCoordinator.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import Foundation
import ReRouter

final class ListCoordinator: ControllerCoordinator {
    enum Key: PathKey {
        case push, present, alert
    }
    
    let controller = storyboard.instantiateViewController(withIdentifier: "list") as! UINavigationController
    
    func item(for key: Key) -> NavigationItem {
        switch key {
        case .push:
            let target = storyboard.instantiateViewController(withIdentifier: "push")
            return NavigationItem(self, target, push: { (animated, source, target, completion) in
                source.controller.pushViewController(target, animated: animated)
                completion()
            }, pop: { (animated, source, target, completion) in
                source.controller.popViewController(animated: animated)
                completion()
            })
        case .present:
            let target = storyboard.instantiateViewController(withIdentifier: "present")
            return present(target)
        case .alert:
            let alert = UIAlertController(title: "alert", message: "example of alert", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                mainStore.dispatch(App.Actions.hideController)
            }))
            return present(alert)
        }
    }
    
}
