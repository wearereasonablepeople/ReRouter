//
//  TestRoutable.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
import RxSwift
@testable import ReRouter

class TestRoutable: XCTestCase {
    
    func testNavigationItem() {
        let coord = Coordinator(id: 1)
        let otherCoordinator = Coordinator(id: 2)
        let viewController = UIViewController()
        let pushExpectation = expectation(description: "PushExpectation")
        let popExpectation = expectation(description: "PopExpectation")
        let otherPushExpectation = expectation(description: "OtherPushExpectation")
        let otherPopExpectation = expectation(description: "PopExpectation")
        
        var first = false
        var second = false
        
        let item = NavigationItem(coord, viewController, push: { (animted, source, target, completion) in
            first = true
            completion()
        }, pop: { (animted, source, target, completion) in
            second = true
            completion()
        })
        
        XCTAssertEqual(item.source.unsafeCast(), coord)
        XCTAssertEqual(item.target as? UIViewController, viewController)
        
        let dispFirst = item.action(for: .push, animated: true).subscribe(onNext: {
            XCTAssertTrue(first)
            pushExpectation.fulfill()
        })
        let dispSecond = item.action(for: .pop, animated: true).subscribe(onNext: {
            XCTAssertTrue(second)
            popExpectation.fulfill()
        })
        
        let otherItem = NavigationItem(coord, otherCoordinator, push: { (_, source, target, completion) in
            XCTAssertEqual(source, coord)
            XCTAssertEqual(target, otherCoordinator)
            completion()
        }, pop: { (_, source, target, completion) in
            XCTAssertEqual(source, coord)
            XCTAssertEqual(target, otherCoordinator)
            completion()
        })
        
        let dispThree = otherItem.action(for: .push, animated: true).subscribe(onNext: { otherPushExpectation.fulfill() })
        let dispFour = otherItem.action(for: .pop, animated: true).subscribe(onNext: { otherPopExpectation.fulfill() })
        
        waitForExpectations(timeout: 2.0)
        dispFirst.dispose()
        dispSecond.dispose()
        dispThree.dispose()
        dispFour.dispose()
    }
    
}
