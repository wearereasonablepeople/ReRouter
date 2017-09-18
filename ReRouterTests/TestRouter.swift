//
//  TestRouter.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
import RxSwift
import ReactiveReSwift
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
        var result: [String] = []
        let trans: (Bool) -> (Bool, Coordinator, Coordinator) -> Void = { push in
            return { animated, source, target in
                let type = push ? "push" : "pop"
                let anim = animated ? "anim" : "non-anim"
                result.append("\(type) \(target.id) \(anim)")
            }
        }
        let push = trans(true)
        let pop = trans(false)
        
        func createItems(upto max: Int) -> [NavigationItem] {
            return (1...max).map({
                NavigationItem(Coordinator(id: $0, push: push, pop: pop), Coordinator(id: $0 + 1, push: push, pop: pop), push: Coordinator.push, pop: Coordinator.pop)
            })
        }
        
        let items = createItems(upto: 3)
        let handler = RouteHandler(root: Coordinator(id: 1, push: push, pop: pop), items: items)
        let test = Coordinator.Key.test
        let other = Coordinator.Key.other
        
        let old = Path<Coordinator.Key>([test, test, test])
        
        let newOne = Path<Coordinator.Key>([test, test, other, other])
        let changeOne = RouteChange(handler: handler, old: old, new: newOne)
        XCTAssertEqual(changeOne.remove.map({ $0.source.unsafeCast() as Coordinator }), [3].map(Coordinator.init))
        XCTAssertEqual(changeOne.add.map({ $0.source.unsafeCast() as Coordinator }), [3, 5].map(Coordinator.init))
        XCTAssertEqual(changeOne.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3, 5].map(Coordinator.init))
        XCTAssertEqual(changeOne.toObservables.count, 3)
        XCTAssertFalse(changeOne.isAnimated)
        
        let expectOne = expectation(description: "OneExpectation")
        let disposableOne = Observable.concat(changeOne.toObservables).subscribe(onCompleted: { expectOne.fulfill() })
        waitForExpectations(timeout: 2.0)
        disposableOne.dispose()
        XCTAssertEqual(result, ["pop 4 non-anim", "push 5 non-anim", "push 7 non-anim"])
        
        let newTwo = Path<Coordinator.Key>([test, test, test, other])
        let changeTwo = RouteChange(handler: handler, old: old, new: newTwo)
        XCTAssertEqual(changeTwo.remove.count, 0)
        XCTAssertEqual(changeTwo.add.map({ $0.source.unsafeCast() as Coordinator }), [4].map(Coordinator.init))
        XCTAssertEqual(changeTwo.new.items.map({ $0.source.unsafeCast() as Coordinator }), [1, 2, 3, 4].map(Coordinator.init))
        XCTAssertEqual(changeTwo.toObservables.count, 1)
        XCTAssertTrue(changeTwo.isAnimated)
        
        result = []
        let expectTwo = expectation(description: "TwoExpectation")
        let disposableTwo = Observable.concat(changeTwo.toObservables).subscribe(onCompleted: { expectTwo.fulfill() })
        waitForExpectations(timeout: 2.0)
        disposableTwo.dispose()
        XCTAssertEqual(result, ["push 6 anim"])
        
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
        
        result = []
        let expectFour = expectation(description: "FourExpectation")
        let disposableFour = Observable.concat(changeFour.toObservables).subscribe(onCompleted: { expectFour.fulfill() })
        waitForExpectations(timeout: 2.0)
        disposableFour.dispose()
        XCTAssertEqual(result, ["pop 4 non-anim", "pop 3 non-anim", "pop 2 non-anim", "push 3 non-anim", "push 5 non-anim", "push 7 non-anim"])
        
        
        XCTAssertTrue(RouteChange(handler: handler, old: old, new: old).isEmpty)
        XCTAssertFalse(changeOne.isEmpty)
        
        let controllerPath = old.push(Coordinator.Key.push)
        let controllerHandler = RouteChange(handler: handler, old: old, new: old.push(Coordinator.Key.push)).new
        let controllerChange = RouteChange(handler: controllerHandler, old: controllerPath, new: controllerPath)
        
        XCTAssertTrue(controllerChange.add.isEmpty)
        XCTAssertTrue(controllerChange.remove.isEmpty)
    }
    
    func testRouter() {
        struct State: NavigatableState {
            var path = Path<Coordinator.Key>(.other)
        }
        
        var result: [String] = []
        let root = Coordinator(id: 1, push: { result.append("push \($0.2.id)") }, pop: { result.append("pop \($0.2.id)") })
        let mainStore = Store(reducer: { $0.1 }, observable: Variable(State()))
        let router = NavigationRouter(root, store: mainStore)
        let successExpectation = expectation(description: "RouteExpectation")
        
        router.setupUpdate()
        mainStore.observable.value.path = Path(.other)
        mainStore.observable.value.path = Path(.test).push(Coordinator.Key.other).push(Coordinator.Key.other)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(result, ["push 3", "pop 3", "push 2", "push 4", "push 6"])
            successExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
}
