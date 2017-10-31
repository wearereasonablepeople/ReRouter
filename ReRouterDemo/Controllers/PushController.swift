//
//  PushController.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit

class PushController: UIViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            mainStore.dispatch(App.Actions.popController)
        }
    }
}
