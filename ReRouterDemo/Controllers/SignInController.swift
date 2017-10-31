//
//  SignInController.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit

class SignInController: UIViewController {
    @IBAction func signInPressed(sender: UIButton) {
        mainStore.dispatch(App.Actions.signIn)
    }
}
