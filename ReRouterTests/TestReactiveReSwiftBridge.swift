//
//  TestReactiveReSwiftBridge.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
import ReRouter
import RxSwift

class TestReactiveReSwiftBridge: XCTestCase {
    
    func testOptinalUnwrap() {
        let successExpectation = expectation(description: "UnwrapExpectation")
        let observable = Observable<Int?>.just(3).unwrap().subscribe(onNext: { value in
            XCTAssertEqual(value, 3)
            successExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0)
        observable.dispose()
    }
    
}
