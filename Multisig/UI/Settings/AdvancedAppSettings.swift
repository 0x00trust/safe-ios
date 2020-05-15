//
//  AdvancedAppSettings.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 15.05.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import SwiftUI

struct AdvancedAppSettings: View {

    let rowHeight: CGFloat = 68

    var body: some View {
        List {
            Section(header: SectionHeader("ENS RESOLVER ADDRESS")) {
                AddressCell(address: App.shared.ens.registryAddress.hex(eip55: true))
            }

            Section(header: SectionHeader("ENDPOINTS")) {
                KeyValueRow("RPC endpoint",
                            DisplayURL(App.shared.nodeService.url).absoluteString)
                KeyValueRow("Transaction service",
                            DisplayURL(App.shared.safeTransactionService.url).absoluteString)
            }
        }
        .navigationBarTitle("Advanced")
    }
}

struct KeyValueRow: View {

    var key: String
    var value: String

    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }

    var body: some View {
        VStack(alignment: .leading) {
            BoldText(key)
            Text(value)
                .font(Font.gnoBody.weight(.medium))
                .foregroundColor(Color.gnoMediumGrey)
        }
    }
}

struct AdvancedAppSettings_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedAppSettings()
    }
}
