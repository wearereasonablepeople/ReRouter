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
        var length = 0
        
        for (left, right) in zip(sequence, new.sequence) {
            guard left.isEqual(to: right) else { break }
            length += 1
        }
        
        return length
    }
    
    /// Check the equality of 2 paths. Complexity: O(n)
    public static func == (lhs: Path<Initial>, rhs: Path<Initial>) -> Bool {
        return lhs.sequence.count == rhs.sequence.count && lhs.commonLength(with: rhs) == lhs.sequence.count
    }
}
