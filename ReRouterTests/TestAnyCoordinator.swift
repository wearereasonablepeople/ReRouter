//
//  TestAnyCoordinator.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
@testable import ReRouter

struct Coordinator: CoordinatorType, Equatable {
    enum Key: PathKey {
        case test, other, push
    }
    
    let id: Int
    let push: (Bool, Coordinator, Coordinator) -> Void
    let pop: (Bool, Coordinator, Coordinator) -> Void
    
    static let push: (Bool, Coordinator, Coordinator, @escaping () -> Void) -> Void = { (animated, source, target, completion) in
        source.push(animated, source, target)
        completion()
    }
    
    static let pop: (Bool, Coordinator, Coordinator, @escaping () -> Void) -> Void = { (animated, source, target, completion) in
        source.pop(animated, source, target)
        completion()
    }
    
    init(id: Int, push: @escaping (Bool, Coordinator, Coordinator) -> Void, pop: @escaping (Bool, Coordinator, Coordinator) -> Void) {
        self.id = id
        self.push = push
        self.pop = pop
    }
    
    init(id: Int) {
        self.id = id
        push = { _ in }
        pop = { _ in }
    }
    
    func item(for key: Key) -> NavigationItem {
        let newId: Int
        switch key {
        case .test: newId = id + 1
        case .other: newId = id + 2
        case .push:
            return NavigationItem(self, UIViewController(), push: { $0.3() }, pop: { $0.3() })
        }
        return NavigationItem(self, Coordinator(id: newId, push: push, pop: pop), push: Coordinator.push, pop: Coordinator.pop)
    }
    
    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs.id == rhs.id
    }
}

class TestAnyCoordinator: XCTestCase {
    
    func testAnyIdentifier() {
        XCTAssertTrue(AnyIdentifier(Coordinator.Key.test).isEqual(to: Coordinator.Key.test))
    }
    
    func testAnyCoordinator() {
        let coordinator = AnyCoordinator(Coordinator(id: 1))
        let key = AnyIdentifier(Coordinator.Key.test)
        XCTAssertEqual((coordinator.item(for: key).target as! AnyCoordinator).unsafeCast(), Coordinator(id: 2))
    }
    
}
