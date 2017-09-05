//
//  TestRouter.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
import RxSwift
@testable import ReRouter

class TestRouter: XCTestCase {
    
    fileprivate let transition: (Bool, Coordinator, Coordinator, @escaping () -> Void) -> Void = { _ in }
    
    func items(upto max: Int) -> [NavigationItem] {
        return (1...max).map({
            NavigationItem(Coordinator(id: $0), Coordinator(id: $0 + 1), push: transition, pop: transition)
        })
    }
    
    func testRemovingPath() {
        let handler = RouteHandler(root: Coordinator(id: 1), items: items(upto: 3))
        XCTAssertTrue(handler.remove(same: 3).isEmpty)
        XCTAssertEqual(handler.remove(same: 1).map({ $0.source.unsafeCast() as Coordinator }), [2, 3].map(Coordinator.init))
    }
    
    func testAddingPath() {
        let items = self.items(upto: 3)
        let handler = RouteHandler(root: Coordinator(id: 1), items: items)
        let id = Coordinator.Key.test
        let path = Path<Coordinator.Key>([id, id, id])
        
        XCTAssertEqual(handler.add(path: path, same: 3).map({ $0.source.unsafeCast() as Coordinator }), [])
        XCTAssertEqual(handler.add(path: path, same: 1).map({ $0.source.unsafeCast() as Coordinator }), [2, 3].map(Coordinator.init))
        XCTAssertEqual(handler.add(path: path, same: 0).map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3].map(Coordinator.init))
    }
    
    func testNavigationChange() {
        let items = self.items(upto: 3)
        let handler = RouteHandler(root: Coordinator(id: 1), items: items)
        let test = Coordinator.Key.test
        let other = Coordinator.Key.other
        
        let old = Path<Coordinator.Key>([test, test, test])
        
        let newOne = Path<Coordinator.Key>([test, test, other, other])
        let changeOne = RouteChange(handler: handler, old: old, new: newOne)
        XCTAssertEqual(changeOne.remove.map({ $0.source.unsafeCast() as Coordinator }), [3].map(Coordinator.init))
        XCTAssertEqual(changeOne.add.map({ $0.source.unsafeCast() as Coordinator }), [3, 5].map(Coordinator.init))
        XCTAssertEqual(changeOne.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3, 5].map(Coordinator.init))
        XCTAssertEqual(changeOne.toObservables.count, 3)
        
        let newTwo = Path<Coordinator.Key>([test, test, test, other])
        let changeTwo = RouteChange(handler: handler, old: old, new: newTwo)
        XCTAssertEqual(changeTwo.remove.count, 0)
        XCTAssertEqual(changeTwo.add.map({ $0.source.unsafeCast() as Coordinator }), [4].map(Coordinator.init))
        XCTAssertEqual(changeTwo.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3, 4].map(Coordinator.init))
        XCTAssertEqual(changeTwo.toObservables.count, 1)
        
        let newThree = Path<Coordinator.Key>([test])
        let changeThree = RouteChange(handler: handler, old: old, new: newThree)
        XCTAssertEqual(changeThree.remove.map({ $0.source.unsafeCast() as Coordinator }), [2, 3].map(Coordinator.init))
        XCTAssertEqual(changeThree.add.count, 0)
        XCTAssertEqual(changeThree.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1].map(Coordinator.init))
        XCTAssertEqual(changeThree.toObservables.count, 2)
        
        let newFour = Path<Coordinator.Key>([other, other, other])
        let changeFour = RouteChange(handler: handler, old: old, new: newFour)
        XCTAssertEqual(changeFour.remove.map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3].map(Coordinator.init))
        XCTAssertEqual(changeFour.add.map({ $0.source.unsafeCast() as Coordinator }), [1, 3, 5].map(Coordinator.init))
        XCTAssertEqual(changeFour.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1, 3, 5].map(Coordinator.init))
        XCTAssertEqual(changeFour.toObservables.count, 6)
    }
    
}
