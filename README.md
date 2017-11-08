# ReRouter
Routing with ReactiveReSwift and RxSwift

[![Build Status](https://travis-ci.org/wearereasonablepeople/ReRouter.svg?branch=master)](https://travis-ci.org/wearereasonablepeople/ReRouter) 
[![codecov](https://codecov.io/gh/wearereasonablepeople/ReRouter/branch/master/graph/badge.svg)](https://codecov.io/gh/wearereasonablepeople/ReRouter)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Overview

ReRouter is library that helps you handle the navigation in the app with [ReactiveReSwift](https://github.com/ReSwift/ReactiveReSwift) and [RxSwift](https://github.com/ReactiveX/RxSwift). ReRouter provides a `Path` type that incapsulated the current navigation of the App and whenever the path is changed, the router will perform all the changes automatically.

# Demo

If you are looking for concrete understanding on how to use this library, there is a demo target in the project where you can find some examples on how to create an app with simple navigation flow.

# How to use

There are 3 main components in Router:

1. [Coordinators](#coordinators)
2. [Path](#path)
3. [Router](#router)

The general flow is the following: You set the new `Path` to the app state, the Router listens to the `Path` changes, generates the difference between two `Paths` and then applys the sequence of navigation side effect, by calling the respective functions in corresponding `Coordinators`

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

## Path

The actual state of the navigation is incapsulated in a `Path` type. You can think of the `Path` as the URL in the web, although it is more powerful, as it not represented as a string. Path is sequence of `Key` that you defined in the Coordinators.

Here is an example of the `Path`:

```swift
Path<AppCoordinator.Key>(.routeList).push(RouteCoordinator.Key.addRoute)
```

Framework provides the the protocol `NavigatableState` that your App State should conform to. Here is an example of the State:

```swift
struct State: NavigatableState {
    var counter = 0
    var path = Path<AppCoordinator.Key>(.logIn)
}
```

The state needs to contain the variable with the path. The router will listen to the changes of the `Path` and perform the side effects.

## Router

The actual navigation is done by `NavigationRouter`. You need to initialiaze the `NavigationRouter` with the initial `Coordinator` and the store that contains your state. You can keep in `AppDelegate`, for example.

Here's the example of your `AppDelegate`:

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let router = NavigationRouter(AppCoordinator(), store: mainStore)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        router.setupUpdate()
        return true
    }
}
```

That's it! You are now ready to use `ReRouter`
