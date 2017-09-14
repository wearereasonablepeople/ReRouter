# ReRouter
Routing with ReactiveReSwift and RxSwift

[![Build Status](https://travis-ci.org/wearereasonablepeople/ReRouter.svg?branch=master)](https://travis-ci.org/wearereasonablepeople/ReRouter) 
[![codecov](https://codecov.io/gh/wearereasonablepeople/ReRouter/branch/master/graph/badge.svg)](https://codecov.io/gh/wearereasonablepeople/ReRouter)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Overview

ReRouter is library that helps you handle the navigation in the app with [ReactiveReSwift](https://github.com/ReSwift/ReactiveReSwift) and [RxSwift](https://github.com/ReactiveX/RxSwift). ReRouter provides a `Path` type that incapsulated the current navigation of the App and whenever the path is changed, the router will perform all the changes automatically.

# How to use

There are 3 main components in Router:

1. [Coordinators](#coordinators)
2. [Path](#path)
3. [Router](#router)

## Coordinators

The actual navigation is done in coordinators. Coordinator is not a new concept and [here](https://vimeo.com/144116310) is a great introduction to it. In ReReouter Coordinators provide 2 things: enum `Key` which you can think of as a Path Item and a method of how to perform the navigation for a give `Key`.

Here's an example of `Coordinator`:

```swift
final class Coordinator: CoordinatorType {
    enum Key: PathKey {
        case presentOther, pushOther
    }
    
    let navigationController: UINavigationController // Initialize navigation controller from storyboard
    
    func item(for key: Key) -> NavigationItem {
        switch key {
        case .presentOther:
            let otherController: UIViewController // Initialize other controller
            return NavigationItem(self, otherController, push: { (animated, source, target, completion) in
                source.navigationController.present(target, animated: animated, completion: completion)
            }, pop: { (animated, source, target, completion) in
                target.dismiss(animated: animated, completion: completion)
            })
        case .pushOther:
            let otherController: UIViewController // Initialize other controller
            return NavigationItem(self, otherController, push: { (animated, source, target, completion) in
                source.navigationController.pushViewController(target, animated: animated)
                completion()
            }, pop: { (animated, source, target, completion) in
                source.navigationController.popViewController(animated: animated)
                completion()
            })
        }
    }
}
```

As you can see, the in method `func item(for key: Key) -> NavigationItem` we have to return `NavigationItem`. NavigationItem is a Type that incapsulates the transition to the next coordinator or view controller.

`NavigationItem` contains of 4 things:

1. `Source` is the coordinator that initiates the transition. It's always `self`.
2. `Target` - this is the next coordinator or `UIViewController` that needs to be presented. In general, anything that conforms to protocol `Routable` can be the target
3. `Push` function. Here we actually perform the transition to `Target`. Animated property indicates whether the transition should be animated. We have to call the completion once the transition is done.
4. `Pop` function. Here we perform the transition back to `Source` from `Target`. Animated property indicates whether the transition should be animated. We have to call the completion once the transition is done.
