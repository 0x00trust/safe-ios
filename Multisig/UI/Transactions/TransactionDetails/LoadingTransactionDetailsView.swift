//
//  LoadingTransactionDetailsView.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 02.10.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import SwiftUI
import Combine

struct LoadingTransactionDetailsView: View {
    var transaction: TransactionViewModel
    @ObservedObject
    var model: StateMachineTransactionDetailsViewModel
    @ObservedObject
    var appSettings = App.shared.settings

    var body: some View {
        NetworkContentView(status: model.status, reload: reload) {
            TransactionDetailsOuterBodyView(
                transactionModel: model.result, reload: reload, confirm: confirm, canSign: model.canSign)
        }
        .onReceive(appSettings.$signingKeyAddress) { _ in
            self.model.status = .initial
        }
        .onAppear {
            trackEvent(.transactionsDetails)
        }
        .navigationBarTitle("Transaction Details", displayMode: .inline)
    }

    private func reload() {
        model.reload(transaction: transaction)
    }

    private func confirm() {
        model.sign()
    }
}

extension LoadingTransactionDetailsView {
    init(transaction: TransactionViewModel) {
        self.transaction = transaction
        model = AppViewModel.shared.details(transaction)
    }
}

struct TransactionDetailsOuterBodyView: View {
    var transactionModel: TransactionViewModel
    var reload: () -> Void
    var confirm: () -> Void
    var canSign: Bool
    @State
    private var showsLink: Bool = false
    private let padding: CGFloat = 11

    var body: some View {
        ZStack {
            List {
                ReloadButton(reload: reload)

                if transactionModel is CreationTransactionViewModel {
                    CreationTransactionBodyView(transaction: transactionModel as! CreationTransactionViewModel)
                } else {
                    TransactionDetailsInnerBodyView(transactionModel: transactionModel)
                }

                if transactionModel.browserURL != nil {
                    viewTxOnEtherscan
                }
            }

            if App.configuration.toggles.signing && canSign {
                confirmButtonView
            }
        }
    }

    private var confirmButtonView: some View {
        VStack {
            Spacer()

            Button(action: confirm) {
                Text("Confirm")
            }
            .buttonStyle(GNOFilledButtonStyle())
            .padding()
        }
    }

    private var viewTxOnEtherscan: some View {
        Button(action: { self.showsLink.toggle() }) {
            LinkText(title: "View transaction on Etherscan")
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(.gnoHold)
        .sheet(isPresented: $showsLink, content: browseTransaction)
        .padding(.vertical, padding)
    }

    private func browseTransaction() -> some View {
        SafariViewController(url: transactionModel.browserURL!)
    }
}

struct TransactionDetailsInnerBodyView: View {
    var transactionModel: TransactionViewModel

    private let padding: CGFloat = 11

    private var dataDecoded: DataDecoded? {
        guard let customTransaction = transactionModel as? CustomTransactionViewModel else {
            return nil
        }

        return customTransaction.dataDecoded
    }

    private var displayConfirmations: Bool {
        guard let transferTransaction = transactionModel as? TransferTransactionViewModel else {
            return true
        }

        return transferTransaction.isOutgoing
    }

    private var data: (length: UInt256, data: String)? {
        guard let customTransaction = transactionModel as? CustomTransactionViewModel,
              let data = customTransaction.data else {
            return nil
        }

        return (length: customTransaction.dataLength, data: data)
    }

    var body: some View {
        Group {
            TransactionHeaderView(transaction: transactionModel)

            if dataDecoded != nil {
                TransactionActionView(dataDecoded: dataDecoded!)
            }

            if data != nil {
                VStack (alignment: .leading) {
                    Text("Data").headline()
                    ExpandableButton(title: "\(data!.length) Bytes", value: data!.data)
                }.padding(.vertical, padding)
            }

            TransactionStatusTypeView(transaction: transactionModel)
            if displayConfirmations {
                TransactionConfirmationsView(transaction: transactionModel).padding(.vertical, padding)
            }

            if transactionModel.formattedCreatedDate != nil {
                KeyValueRow("Created:",
                            value: transactionModel.formattedCreatedDate!,
                            enableCopy: false,
                            color: .gnoDarkGrey).padding(.vertical, padding)
            }

            if transactionModel.formattedExecutedDate != nil {
                KeyValueRow("Executed:",
                            value: transactionModel.formattedExecutedDate!,
                            enableCopy: false,
                            color: .gnoDarkGrey).padding(.vertical, padding)
            }

            if transactionModel.hasAdvancedDetails {
                NavigationLink(destination: AdvancedTransactionDetailsView(transactionViewModel: transactionModel)) {
                    Text("Advanced").body()
                }
                .frame(height: 48)
            }
        }
    }
}
