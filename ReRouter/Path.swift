//
//  Path.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import Foundation

public protocol NavigatableState {
    associatedtype Initial: PathIdentifier
    var path: Path<Initial> { get }
}

public struct Path<Initial: PathIdentifier>: Equatable {
    public var sequence: [PathIdentifier]
    
    public init(_ initial: Initial) {
        sequence = [initial]
    }
    
    public init(_ sequence: [PathIdentifier]) {
        self.sequence = sequence
    }
    
    public mutating func append<T: PathIdentifier>(_ id: T) {
        sequence.append(id)
    }
    
    public mutating func removeLast() {
        sequence.removeLast()
    }
    
    public func push<T: PathIdentifier>(_ id: T) -> Path<Initial> {
        var new = self
        new.append(id)
        return new
    }
    
    public func dropLast() -> Path<Initial> {
        var new = self
        new.removeLast()
        return new
    }
    
    /// Size of the common keys with other path. Complexity: O(n)
    func commonLength(with new: Path<Initial>) -> Int {
        return zip(sequence, new.sequence).reduce((true, 0), {
            $0.0 && $1.0.isEqual(to: $1.1) ? (true, $0.1 + 1) : (false, $0.1)
        }).1
    }
    
    public static func == (lhs: Path<Initial>, rhs: Path<Initial>) -> Bool {
        return lhs.sequence.count == rhs.sequence.count
            && zip(lhs.sequence, rhs.sequence).reduce(true, { $0.0 && $0.1.0.isEqual(to: $0.1.1) })
    }
}
