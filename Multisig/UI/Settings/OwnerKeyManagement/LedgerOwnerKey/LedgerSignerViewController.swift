//
//  LedgerSignerViewController.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 07.10.21.
//  Copyright © 2021 Gnosis Ltd. All rights reserved.
//

import UIKit

struct SignRequest {
    var title: String
    var tracking: [String: Any]
    var signer: KeyInfo
    var hexToSign: String
}

class LedgerSignerViewController: UINavigationController {

    var request: SignRequest!

    var completion: ((String) -> Void)!

    var onClose: (() -> Void)? {
        didSet {
            if let vc = viewControllers.first as? SelectLedgerDeviceViewController {
                vc.onClose = onClose
            }
        }
    }

    convenience init(request: SignRequest) {
        assert(request.signer.keyType == .ledgerNanoX)
        let vc = SelectLedgerDeviceViewController(trackingParameters: request.tracking,
                                                  title: request.title,
                                                  showsCloseButton: true)
        self.init(rootViewController: vc)
        self.request = request
        vc.delegate = self
    }
}

extension LedgerSignerViewController: SelectLedgerDeviceDelegate {
    func selectLedgerDeviceViewController(
        _ controller: SelectLedgerDeviceViewController,
        didSelectDevice deviceId: UUID,
        bluetoothController: BaseBluetoothController
    ) {
        guard let data = request.signer.metadata, let metadata = KeyInfo.LedgerKeyMetadata.from(data: data) else { return }

        let confirmVC = LedgerPendingConfirmationViewController(
            bluetoothController: bluetoothController,
            hexToSign: request.hexToSign,
            deviceId: deviceId,
            derivationPath: metadata.path)

        confirmVC.modalPresentationStyle = .popover
        confirmVC.modalTransitionStyle = .crossDissolve

        present(confirmVC, animated: true)

        confirmVC.onClose = controller.onClose

        confirmVC.onSign = { [weak self, unowned controller] signature in
            guard let self = self else { return }

            // dismiss Ledger Pending Confirmation overlay
            self.dismiss(animated: true, completion: nil)

            guard let signature = signature else {
                // not signed due to some device response.
                // we keep the SelectDeviceVC open because we may need to re-select because of
                // failed ledger connection
                App.shared.snackbar.show(message: "The operation was canceled on the Ledger device.")

                // reload the devices in case we lost connection
                controller.reloadData()
                return
            }

            // got signature, dismiss the first SelectDevice screen.
            self.dismiss(animated: true, completion: nil)

            self.completion(signature)
        }
    }
}
