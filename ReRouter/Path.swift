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
    
    /// Add path id. Complexity: O(1)
    public mutating func append<T: PathIdentifier>(_ id: T) {
        sequence.append(id)
    }
    
    /// Remove last path id. Complexity: O(1)
    public mutating func removeLast() {
        sequence.removeLast()
    }
    
    /// Create new path with additional element. Complexity: O(n)
    public func push<T: PathIdentifier>(_ id: T) -> Path<Initial> {
        var new = self
        new.append(id)
        return new
    }
    
    /// Create new path without last element. Complexity: O(n)
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
    
    /// Check the equality of 2 paths. Complexity: O(n)
    public static func == (lhs: Path<Initial>, rhs: Path<Initial>) -> Bool {
        guard lhs.sequence.count == rhs.sequence.count else { return false }
        
        for (left, right) in zip(lhs.sequence, rhs.sequence) {
            if left.isEqual(to: right) == false {
                return false
            }
        }
        
        return true
    }
}
