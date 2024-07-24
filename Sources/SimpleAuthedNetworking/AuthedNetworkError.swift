//
//  AuthedNetworkError.swift
//  
//
//  Created by Samantha Gatt on 7/24/24.
//

import SimpleNetworking

enum AuthedNetworkError: Error {
    /// Error encounterd while authenticating
    case auth(NetworkError)
    /// Error encountered while performing main network request
    case request(NetworkError)
    
    var underlyingError: NetworkError {
        switch self {
        case .auth(let error), .request(let error): return error
        }
    }
}
