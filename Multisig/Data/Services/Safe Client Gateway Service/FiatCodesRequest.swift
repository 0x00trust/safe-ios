//
//  BalancesRequest.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 02.11.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

struct FiatCodesRequest: JSONRequest {
    let chainId: Int
    
    var httpMethod: String { "GET" }

    var urlPath: String {
        "/\(chainId)/v1/balances/supported-fiat-codes"
    }

    typealias ResponseType = [String]
}

extension SafeClientGatewayService {
    func fiatCurrencies(completion: @escaping (Result<FiatCodesRequest.ResponseType, Error>) -> Void) -> URLSessionTask? {
        asyncExecute(request: FiatCodesRequest(chainId: chainId), completion: completion)
    }
}
