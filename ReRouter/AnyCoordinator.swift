//
//  AnyCoordinator.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import Foundation

struct AnyIdentifier: PathIdentifier {
    let base: PathIdentifier
    
    init(_ base: PathIdentifier) {
        self.base = base
    }
    
    func isEqual(to other: PathIdentifier) -> Bool {
        return base.isEqual(to: other)
    }
}

struct AnyCoordinator: CoordinatorType {
    private let box: _AnyCoordinatorBoxBase
    
    public init<V: CoordinatorType>(_ CoordinatorType: V) {
        box = _AnyCoordinatorConcreteBox(CoordinatorType)
    }
    
    func item(for identifier: AnyIdentifier) -> NavigationItem {
        return box.item(for: identifier)
    }
    
    func unsafeCast<V: CoordinatorType>() -> V {
        return box.unsafeCast()
    }
}

private class _AnyCoordinatorBoxBase: CoordinatorType {
    func item(for identifier: AnyIdentifier) -> NavigationItem {
        fatalError()
    }
    
    func unsafeCast<T: CoordinatorType>() -> T {
        fatalError()
    }
}

private final class _AnyCoordinatorConcreteBox<V: CoordinatorType>: _AnyCoordinatorBoxBase {
    let base: V
    
    init(_ base: V) {
        self.base = base
    }
    
    override func item(for identifier: AnyIdentifier) -> NavigationItem {
        guard let identifier = identifier.base as? V.Key else { fatalError("Wrong identifier") }
        return base.item(for: identifier)
    }
    
    override func unsafeCast<T : CoordinatorType>() -> T {
        return base as! T
    }
}
