//
//  LedgerKeyAddedViewController.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 05.10.21.
//  Copyright © 2021 Gnosis Ltd. All rights reserved.
//

import UIKit

class LedgerKeyAddedViewController: AccountActionCompletedViewController {
    private var addKeyController: DelegateKeyController!

    convenience init() {
        self.init(namedClass: AccountActionCompletedViewController.self)
    }

    override func viewDidLoad() {
        titleText = "Connect Ledger Nano X"
        headerText = "Owner Key added"

        assert(accountName != nil)
        assert(accountAddress != nil)

        descriptionText = "\(accountName ?? "Key") can't receive push notifications without your confirmation."

        primaryActionName = "Confirm to receive push notifications"
        secondaryActionName = "Skip"

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tracker.trackEvent(.addDelegateKeyLedger)
    }

    override func primaryAction(_ sender: Any) {
        // Start Add Delegate flow with the selected account address
        Tracker.trackEvent(.addDelegateKeyStarted)
        do {
            addKeyController = try DelegateKeyController(ownerAddress: accountAddress, completion: completion)
            addKeyController.presenter = self
            addKeyController.createDelegate()
        } catch {
            App.shared.snackbar.show(message: error.localizedDescription)
        }
    }

    override func secondaryAction(_ sender: Any) {
        // doing nothing because user skipped
        Tracker.trackEvent(.addDelegateKeySkipped)
        completion()
    }
}
