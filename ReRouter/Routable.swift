//
//  Routable.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import RxSwift

public protocol Routable {}

public protocol CoordinatorType: Routable {
    associatedtype Key: PathIdentifier
    func item(for key: Key) -> NavigationItem
}

public protocol PathIdentifier {
    func isEqual(to other: PathIdentifier) -> Bool
}

public protocol PathKey: Equatable, PathIdentifier {}

public extension PathIdentifier where Self: Equatable {
    public func isEqual(to other: PathIdentifier) -> Bool {
        guard let otherRoute = other as? Self else { return false }
        return self == otherRoute
    }
}

public struct NavigationItem {
    enum ActionType {
        case push, pop
    }
    
    let push: (Bool, AnyCoordinator, Routable, @escaping () -> Void) -> Void
    let pop: (Bool, AnyCoordinator, Routable, @escaping () -> Void) -> Void
    let source: AnyCoordinator
    let target: Routable
    
    public init<S: CoordinatorType, T: Routable>(_ source: S, _ target: T, push: @escaping ((Bool, S, T, @escaping () -> Void) -> Void), pop: @escaping (Bool, S, T, @escaping () -> Void) -> Void) {
        self.source = AnyCoordinator(source)
        self.target = target
        self.push = { push($0.0, $0.1.unsafeCast(), $0.2 as! T, $0.3) }
        self.pop = { pop($0.0, $0.1.unsafeCast(), $0.2 as! T, $0.3) }
    }
    
    public init<S: CoordinatorType, T: CoordinatorType>(_ source: S, _ target: T, push: @escaping ((Bool, S, T, @escaping () -> Void) -> Void), pop: @escaping ((Bool, S, T, @escaping () -> Void) -> Void)) {
        self.source = AnyCoordinator(source)
        self.target = AnyCoordinator(target)
        self.push = { push($0.0, $0.1.unsafeCast(), ($0.2 as! AnyCoordinator).unsafeCast(), $0.3) }
        self.pop = { pop($0.0, $0.1.unsafeCast(), ($0.2 as! AnyCoordinator).unsafeCast(), $0.3) }
    }
    
    func action(for actionType: ActionType, animated: Bool) -> Observable<Void> {
        let action = actionType == .push ? push: pop
        return .create({ observer -> Disposable in
            action(animated, self.source, self.target, {
                observer.onNext()
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}

extension UIViewController: Routable {}
