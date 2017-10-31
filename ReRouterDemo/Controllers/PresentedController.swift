//
//  PresentedController.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit

class PresentedController: UIViewController {
    @IBAction func dismissButtonPressed(sender: UIButton) {
        mainStore.dispatch(App.Actions.hideController)
    }
}
