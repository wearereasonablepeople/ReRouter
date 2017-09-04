//
//  TestPath.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import XCTest
@testable import ReRouter

extension String: PathIdentifier {}
extension Int: PathIdentifier {}

class TestPath: XCTestCase {
    func testGettingSameSubsequence() {
        let item = Path<String>(["1", "2", "3"])
        XCTAssertEqual(item.commonLength(with: item.dropLast()), 2)
        XCTAssertEqual(item.commonLength(with: item.push("4")), 3)
        XCTAssertEqual(item.commonLength(with: Path(["2", "3", "1"])), 0)
        XCTAssertEqual(item.commonLength(with: item), item.sequence.count)
    }
    
    func testPathEquatable() {
        let item = Path<String>(["1", "2", "3"])
        
        XCTAssertEqual(item, item)
        XCTAssertEqual(Path<String>("1"), Path(["1"]))
        XCTAssertNotEqual(item, item.push("4"))
        XCTAssertNotEqual(item, Path(["1", "2", 4]))
    }
}
