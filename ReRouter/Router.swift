//
//  Router.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import RxSwift
import ReactiveReSwift

struct RouteChange<Root: CoordinatorType> {
    let remove: [NavigationItem]
    let add: [NavigationItem]
    let new: RouteHandler<Root>
    let path: Path<Root.Key>
    
    init(handler: RouteHandler<Root>, old: Path<Root.Key>, new: Path<Root.Key>) {
        let same = old.commonLength(with: new)
        remove = handler.remove(same: same)
        add = handler.add(path: new, same: same)
        path = new
        self.new = RouteHandler(root: handler.root, items: handler.items[0..<same] + add)
    }
    
    var toObservables: [Observable<Void>] {
        let remove = self.remove.reversed().map({ $0.action(for: .pop, animated: isAnimated) })
        let add = self.add.map({ $0.action(for: .push, animated: isAnimated) })
        return remove + add
    }
    
    var isEmpty: Bool {
        return remove.isEmpty && add.isEmpty
    }
    
    var isAnimated: Bool {
        return (remove.count + add.count) == 1
    }
}

struct RouteHandler<Root: CoordinatorType> {
    let root: Root
    let items: [NavigationItem]
    
    func remove(same: Int) -> [NavigationItem] {
        return Array(items[same..<items.count])
    }
    
    func add(path: Path<Root.Key>, same: Int) -> [NavigationItem] {
        let initial = same > 0 ? items[same - 1].target : AnyCoordinator(root)
        var result = [NavigationItem]()
        _ = path.sequence[same..<path.sequence.count]
            .lazy.map(AnyIdentifier.init)
            .reduce(initial, { (item, current) in
                let new = (item as! AnyCoordinator).item(for: current)
                result.append(new)
                return new.target
            })
        
        return result
    }
}

public final class NavigationRouter<Root: CoordinatorType, State: NavigatableState> where Root.Key == State.Initial {
    public let store: Store<Variable<State>>
    let disposeBag = DisposeBag()
    var handler: RouteHandler<Root>
    
    public init(_ root: Root, store: Store<Variable<State>>) {
        self.store = store
        handler = RouteHandler(root: root, items: [])
    }
    
    public func setupUpdate() {
        store.observable
            .asObservable()
            .map({ $0.path })
            .scan((Path(), Path()), accumulator: { ($0.1, $1) })
            .map({ [unowned self] in RouteChange(handler: self.handler, old: $0.0, new: $0.1) })
            .filter({ $0.isEmpty == false })
            .do(onNext: { [unowned self] in self.handler = $0.new })
            .flatMap({ change -> Observable<Void> in
                if change.path.isSilent {
                    return Observable.just(())
                } else {
                    return Observable.concat(change.toObservables)
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
}
