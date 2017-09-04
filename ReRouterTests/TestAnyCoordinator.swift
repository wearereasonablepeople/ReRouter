//
//  TestAnyCoordinator.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
@testable import ReRouter

private struct Coordinator: CoordinatorType, Equatable {
    enum Key: PathKey {
        case test, other
    }
    
    let id: Int
    
    func item(for identifier: Key) -> NavigationItem {
        let newId: Int
        switch identifier {
        case .test:
            newId = id + 1
        case .other:
            newId = id + 2
        }
        return NavigationItem(self, Coordinator(id: newId), push: { _ in }, pop: { _ in })
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
