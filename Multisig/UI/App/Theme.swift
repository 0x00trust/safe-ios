//
//  Theme.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 13.05.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class Theme: ObservableObject {

    private var tableViewBackgroundColor: UIColor?

    func setUp() {
        // we don't set the image for the navbar (pdf) as it crashes the app;
        // we don't set the `translucent` property of navbar to false because
        // it crashes the app (SwiftUI).
        // but shadow works.
        UINavigationBar.appearance().shadowImage = nil
        UINavigationBar.appearance().tintColor = .primary
  
        // non-zero height view adds the bottom space to the table views
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        // makes separators to take full width of the screen
        // (default is with offset)
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        UITableView.appearance().separatorColor = .separator
        // we don't touch the UITableView appearance background color
        // because it messes up the backgrounds when navigating in the app

        setDisplayMode()
    }

    private func setDisplayMode() {
        UIApplication.shared.windows.filter(\.isKeyWindow).first?.overrideUserInterfaceStyle = displayMode
    }

    var displayMode: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: Int(AppSettings.displayMode)) ?? .unspecified
        }
        set {
            AppSettings.displayMode = Int32(newValue.rawValue)
            setDisplayMode()
        }
    }

}
