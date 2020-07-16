//
//  TransferTransaction.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 15.06.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation
import SwiftCryptoTokenFormatter

class TransferTransactionViewModel: TransactionViewModel {

    var address: String
    var isOutgoing: Bool
    var amount: String
    var tokenSymbol: String
    var tokenLogoURL: String

    override init() {
        address = ""
        isOutgoing = true
        amount = ""
        tokenSymbol = ""
        tokenLogoURL = ""
        super.init()
    }

    init(outgoing: Bool? = nil, transfer: TransferInfo, tx: Transaction, safe: SafeInfo) {
        isOutgoing = outgoing ?? (transfer.from == tx.safeAddress(safe))

        address = (isOutgoing ? transfer.to : transfer.from).checksummed

        let sign: Int256 = isOutgoing ? -1 : +1
        let decimalAmount = BigDecimal(Int256(transfer.amount) * sign,
                                       Int(clamping: transfer.token.decimals))
        amount = TokenFormatter().string(
            from: decimalAmount,
            decimalSeparator: Locale.autoupdatingCurrent.decimalSeparator ?? ".",
            thousandSeparator: Locale.autoupdatingCurrent.groupingSeparator ?? ",",
            forcePlusSign: true
        )
        tokenSymbol = transfer.token.symbol
        tokenLogoURL = transfer.token.logo?.absoluteString ?? ""
        super.init(tx, safe)
    }

    static let erc20Methods: [SmartContractMethodCall.Type] = [MethodRegistry.ERC20.Transfer.self, MethodRegistry.ERC20.TransferFrom.self]
    static let erc721Methods: [SmartContractMethodCall.Type] = [MethodRegistry.ERC721.SafeTransferFrom.self, MethodRegistry.ERC721.SafeTransferFromData.self]
    static let transferMethods: [SmartContractMethodCall.Type] = erc20Methods + erc721Methods

    override class func viewModels(from tx: Transaction, info: SafeStatusRequest.Response) -> [TransactionViewModel] {
        var result = [TransactionViewModel]()

        // ether transaction
        if (tx.txType == .ethereum || tx.txType == .multiSig) && tx.data == nil && tx.operation == .call {
            let token = App.shared.tokenRegistry.token(address: AddressRegistry.ether)!
            let transferInfo = TransferInfo(ether: tx, info: info, token: token)

            result = [etherViewModel(transferInfo, tx, info)]

        // external transaction transferring something
        } else if tx.txType == .ethereum,
            let transfers = tx.transfers,
            !transfers.isEmpty {

            // multiple token transfers
            result = transfers.map { transfer in
                tokenViewModel(token(from: transfer), transfer, tx, info)
            }

        // safe-initiated transaction that is transferring some token
        } else if tx.txType == .multiSig,
            tx.operation == .call,
            tx.to?.address != tx.safeAddress(info),
            let call = MethodRegistry.method(from: tx.dataDecoded, candidates: transferMethods) {

            result = [
                transferViewModel(
                    TransferMethod(call),
                    token(
                        address: tx.to?.address ?? AddressRegistry.ether,
                        data: tx.dataDecoded,
                        safe: tx.safeAddress(info)),
                    tx,
                    info)]
        } else {
            // not a transfer transaction, do nothing
            result = []
        }
        return result
    }

    fileprivate class func token(from transfer: TransactionTransfer) -> Token {
        let token: Token

        if let tokenFromData = transfer.tokenInfo {
            token = Token(tokenFromData)

        } else if let tokenAddress = transfer.tokenAddress?.address,
            let knownToken = App.shared.tokenRegistry.token(address: tokenAddress) {
            token = knownToken

        // treating unknown tokens as erc20 tokens
        } else if let tokenAddress = transfer.tokenAddress?.address {
            token = Token(erc20: tokenAddress)

        // nil token address, i.e. ether
        } else {
            token = App.shared.tokenRegistry.token(address: AddressRegistry.ether)!
        }
        return token
    }

    fileprivate class func token(address: Address, data: TransactionData?, safe: Address) -> Token {
        let token: Token

        if let knownToken = App.shared.tokenRegistry.token(address: address) {
            token = knownToken

        // unknown token, check  if conforms to ERC721
        } else if (try? ERC721(address).supportsInterface(ERC721.Selectors.safeTransferFrom)) == true {
            token = Token(erc721: address)

        // fall back to guess token type based on the method call
        } else if MethodRegistry.method(from: data, candidates: erc721Methods) != nil {
            token = Token(erc721: address)

        } else if MethodRegistry.method(from: data, candidates: erc20Methods) != nil {
            token = Token(erc20: address)

        } else {
            // should not come there because that means that erc20 and erc721 methods
            // were not decoded, which must be true, becuase the outer 'else if' condition
            // is true
            assertionFailure("Should not get here")
            LogService.shared.error("Transfer transaction classification failed in safe:\(safe)")
            token = Token(erc20: address)
        }
        return token
    }

    fileprivate class func tokenViewModel(_ token: Token, _ transfer: TransactionTransfer, _ tx: Transaction, _ info: SafeStatusRequest.Response) -> TransactionViewModel {
        if !((transfer.type == .ether && token.type == .erc20) || (transfer.type == token.type)) {
            assertionFailure("Invalid combination of transfer type and tokenInfo type")
            LogService.shared.error("Transfer transaction has invalid transfer and tokenInfo combination in safe: \(tx.safeAddress(info))")
            // continuing to still display this transfer
        }
        let transferInfo: TransferInfo
        switch token.type {
        case .erc20:
            transferInfo = TransferInfo(erc20: transfer, tx: tx, info: info, token: token)
        case .erc721:
            transferInfo = TransferInfo(erc721: transfer, tx: tx, info: info, token: token)
        }
        return transferViewModel(transferInfo, tx, info)
    }

    fileprivate class func transferViewModel(_ method: TransferMethod, _ token: Token,  _ tx: Transaction, _ info: SafeStatusRequest.Response) -> TransactionViewModel {
        let transferInfo: TransferInfo
        switch token.type {
        case .erc20:
            transferInfo = TransferInfo(erc20: method, tx: tx, info: info, token: token)
        case .erc721:
            transferInfo = TransferInfo(erc721: method, tx: tx, info: info, token: token)
        }
        return transferViewModel(transferInfo, tx, info)
    }

    fileprivate class func etherViewModel(_ transfer: TransactionTransfer, _ tx: Transaction, _ info: SafeStatusRequest.Response) -> TransactionViewModel {
        // ether
        let token = App.shared.tokenRegistry.token(address: AddressRegistry.ether)!

        if transfer.type != .ether {
            assertionFailure("Expected to see ether transfer")
            LogService.shared.error("Transfer transaction has invalid (not ether) transfer type: \(tx.safeAddress(info))")
            // continuing to still display this transfer
        }
        let transferInfo = TransferInfo(ether: transfer, tx: tx, info: info, token: token)
        return transferViewModel(transferInfo, tx, info)
    }

    fileprivate class func etherViewModel(_ transfer: TransferInfo, _ tx: Transaction, _ info: SafeStatusRequest.Response) -> TransactionViewModel {
        return transferViewModel(transfer, tx, info)
    }

    fileprivate class func transferViewModel(_ transfer: TransferInfo, _ tx: Transaction, _ info: SafeStatusRequest.Response) -> TransactionViewModel {
        // populate transfer from decoded data
        let safeAddress = tx.safeAddress(info)
        if transfer.to != safeAddress && transfer.from != safeAddress {
            return CustomTransactionViewModel(transfer: transfer, tx: tx, safe: info)
        }
        return TransferTransactionViewModel(transfer: transfer, tx: tx, safe: info)
    }

}
