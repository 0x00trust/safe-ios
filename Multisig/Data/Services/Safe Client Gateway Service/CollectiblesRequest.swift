//
//  CollectiblesRequest.swift
//  Multisig
//
//  Created by Dmitry Bespalov on 09.07.20.
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

struct CollectiblesRequest: JSONRequest {
    let safeAddress: String
    let networkId: String
    
    var httpMethod: String { "GET" }
    var urlPath: String { "/v1/chains/\(networkId)/safes/\(safeAddress)/collectibles/" }

    typealias ResponseType = [Collectible]
}

extension CollectiblesRequest {
    init(_ safeAddress: Address, networkId: String) {
        self.init(safeAddress: safeAddress.checksummed,
                  networkId: networkId)
    }
}

extension SafeClientGatewayService {
    func asyncCollectibles(safeAddress: Address,
                           networkId: String,
                           completion: @escaping (Result<[Collectible], Error>) -> Void) -> URLSessionTask? {
        asyncExecute(request: CollectiblesRequest(safeAddress, networkId: networkId), completion: completion)
    }
}
