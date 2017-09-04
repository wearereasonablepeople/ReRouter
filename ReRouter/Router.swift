//
//  Router.swift
//  ReRouter
//
//  Created by Oleksii on 04/09/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import Foundation

struct RouteChange<Root: CoordinatorType> {
    let remove: [NavigationItem]
    let add: [NavigationItem]
    let new: RouteHandler<Root>
    
    init(handler: RouteHandler<Root>, old: Path<Root.Key>, new: Path<Root.Key>) {
        let same = old.commonLength(with: new)
        remove = handler.remove(same: same)
        add = handler.add(path: new, same: same)
        self.new = RouteHandler(root:handler.root, items: handler.items[0..<same] + add)
    }
}

struct RouteHandler<Root: CoordinatorType> {
    let root: Root
    let items: [NavigationItem]
    
    func remove(same: Int) -> [NavigationItem] {
        return Array(items[same..<items.count])
    }
    
    func add(path: Path<Root.Key>, same: Int) -> [NavigationItem] {
        let initial = same > 0 ? items[same - 1].target as! AnyCoordinator : AnyCoordinator(root)
        return path.sequence[same..<path.sequence.count]
            .map(AnyIdentifier.init)
            .reduce((Optional.some(initial), [NavigationItem]()), { (item, current) in
                let new = item.0!.item(for: current)
                return (new.target as? AnyCoordinator, item.1 + [new])
            }).1
    }
}
