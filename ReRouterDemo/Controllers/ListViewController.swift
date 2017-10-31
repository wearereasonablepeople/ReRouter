//
//  ViewController.swift
//  ReRouterDemo
//
//  Created by Oleksii on 31/10/2017.
//  Copyright © 2017 WeAreReasonablePeople. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action: App.Actions
        
        switch indexPath.row {
        case 0: action = .pushController
        case 1: action = .presentController
        case 2: action = .showAlert
        default: fatalError()
        }
        
        mainStore.dispatch(action)
    }
    
}

