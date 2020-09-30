//
//  SettingChangeTransactionSummaryViewModel.swift
//  Multisig
//
//  Created by Moaaz on 9/2/20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import UIKit

class SettingChangeTransactionViewModel: TransactionViewModel {
    var title: String = ""
    var info: SettingsChangeTransactionSummaryInfo?

    override func bind(info: TransactionInfo) {
        let settingsChangeTransactionInfo = info as! SettingsChangeTransactionInfo
        title = settingsChangeTransactionInfo.dataDecoded.method
        self.info = settingsChangeTransactionInfo.settingsInfo
    }

    class func isValid(info: TransactionInfo) -> Bool {
        info is SettingsChangeTransactionInfo
    }
    
    override class func viewModels(from tx: SCGTransaction) -> [TransactionViewModel] {
        isValid(info: tx.txInfo) ? [SettingChangeTransactionViewModel(tx)] : []
    }
}
