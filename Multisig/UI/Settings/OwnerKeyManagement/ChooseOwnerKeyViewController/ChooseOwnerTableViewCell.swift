//
//  ChooseOwnerTableViewCell.swift
//  Multisig
//
//  Created by Moaaz on 3/11/21.
//  Copyright © 2021 Gnosis Ltd. All rights reserved.
//

import UIKit

class ChooseOwnerTableViewCell: UITableViewCell {
    @IBOutlet private weak var addressInfoView: AddressInfoView!

    override func awakeFromNib() {
        super.awakeFromNib()
        addressInfoView.copyEnabled = false
        addressInfoView.setDetailImage(nil)
    }

    func set(address: Address, title: String) {
        addressInfoView.setAddress(address, label: title)
    }
}
