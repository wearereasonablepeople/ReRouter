//
//  ControllerCoordinator.swift
//  ReRouter
//
//  Created by Oleksii on 11/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit

public protocol ControllerCoordinator: CoordinatorType {
    associatedtype Controller: UIViewController
    var controller: Controller { get }
}

public extension ControllerCoordinator {
    public func present<T: UIViewController>(_ controller: T) -> NavigationItem {
        return NavigationItem(self, controller, push: { (animated, source, target, completion) in
            source.controller.present(target, animated: animated, completion: completion)
        }, pop: { (animated, source, target, completion) in
            target.dismiss(animated: animated, completion: completion)
        })
    }
    
    public func present<T: ControllerCoordinator>(_ coordinator: T) -> NavigationItem {
        return NavigationItem(self, coordinator, push: { (animated, source, target, completion) in
            source.controller.present(target.controller, animated: animated, completion: completion)
        }, pop: { (animated, source, target, completion) in
            target.controller.dismiss(animated: animated, completion: completion)
        })
    }
}
