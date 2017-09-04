//
//  ReactiveReSwiftBridge.swift
//  ReactiveReSwift-RxSwiftExample
//
//  Created by Charlotte Tortorella on 1/12/16.
//  Copyright © 2016 ReSwift. All rights reserved.
//

import ReactiveReSwift
import RxSwift

extension Variable: ObservablePropertyType {
    public typealias ValueType = Element
    public typealias DisposeType = DisposableWrapper
    
    public func subscribe(_ function: @escaping (Element) -> Void) -> DisposableWrapper? {
        return DisposableWrapper(disposable: asObservable().subscribe(onNext: function))
    }
}

extension Observable: StreamType {
    public typealias ValueType = Element
    public typealias DisposeType = DisposableWrapper
    
    public func subscribe(_ function: @escaping (Element) -> Void) -> DisposableWrapper? {
        return DisposableWrapper(disposable: subscribe(onNext: function))
    }
}

public struct DisposableWrapper: SubscriptionReferenceType {
    let disposable: Disposable
    
    public func dispose() {
        disposable.dispose()
    }
}

public protocol Optionable {
    associatedtype WrappedType
    func unwrap() -> WrappedType
    func isEmpty() -> Bool
}

extension Optional : Optionable {
    public typealias WrappedType = Wrapped
    
    /**
     Force unwraps the contained value and returns it. Will crash if there's no value stored.
     
     - returns: Value of the contained type
     */
    public func unwrap() -> WrappedType {
        return self!
    }
    
    /**
     Returns `true` if the Optional element is `nil` (if it does not contain a value) or `false` if the element *does* contain a value
     
     - returns: `true` if the Optional element is `nil`; false if it *does* have a value
     */
    public func isEmpty() -> Bool {
        return self == nil
    }
}

extension ObservableType where E : Optionable {
    
    /**
     Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.
     
     - returns: An observable sequence of non-optional elements
     */
    
    public func unwrap() -> Observable<E.WrappedType> {
        return self.filter { !$0.isEmpty() }.map { $0.unwrap() }
    }
}
