//
//  ImportedKeyCell.swift
//  Multisig
//
//  Created by Andrey Scherbovich on 11.11.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit

class ImportedKeyCell: UITableViewCell {
    @IBOutlet private weak var addressInfoView: AddressInfoView!

    var onRemove: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        addressInfoView.setDetailsImage(
            UIImage(systemName: "trash",
                    withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!,
            tintColor: .gnoTomato)
        addressInfoView.onDisclosureButtonAction = removeKey
    }

    func setAddressInfo(_ addressInfo: AddressInfo) {
        addressInfoView.setAddressInfo(addressInfo)
    }

    private func removeKey() {
        onRemove?()
    }
}
