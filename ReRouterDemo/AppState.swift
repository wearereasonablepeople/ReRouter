//
//  AppState.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import Foundation
import ReactiveReSwift
import ReRouter
import RxSwift

struct App {
    struct State: NavigatableState {
        var path = Path<AppCoordinator.Key>(.signIn)
    }
    
    enum Actions: Action {
        case pushController
        case popController
        case presentController
        case showAlert
        case hideController
        case signOut
    }
    
    static let reducer: Reducer<State> = { action, state in
        guard let action = action as? Actions else { return state }
        var state = state
        
        switch action {
        case .pushController:
            state.path.append(ListCoordinator.Key.push)
        case .popController:
            state.path = state.path.dropLast().silently()
        case .presentController:
            state.path.append(ListCoordinator.Key.present)
        case .showAlert:
            state.path.append(ListCoordinator.Key.alert)
        case .hideController:
            state.path.removeLast()
        case .signOut:
            state.path = Path(.signIn)
        }
        
        return state
    }
}

let mainStore = Store(
    reducer: App.reducer,
    observable: Variable(App.State())
)
