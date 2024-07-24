//
//  AuthedNetworkManager.swift
//
//
//  Created by Samantha Gatt on 6/8/24.
//

import SimpleNetworking

class AuthedNetworkManager<Token: AuthToken> {
    let networkManager: SimpleNetworkingManager
    private let authTask: PatientTask<Result<Token, AuthedNetworkError>>
    private var currentToken: Token?
    
    init(
        networkManager: SimpleNetworkingManager,
        tokenRefreshReq: any NetworkRequest<Token>,
        currentToken: Token? = nil
    ) {
        self.networkManager = networkManager
        self.currentToken = currentToken
        self.authTask = PatientTask {
            await Self.refreshToken(tokenRefreshReq, networkManager)
        }
    }
    
    func update(authToken: Token) {
        
    }
    
    /// - parameter forceFetchAuthToken: Forces the auth token to be fetched again even if the request does not require authentication
    func load<T>(
        _ request: any NetworkRequest<T>,
        forceFetchAuthToken: Bool
    ) async throws(NetworkError) -> T {
        var authToken: String?
        // if request.requiresAuth || forceFetchAuthToken {
        //     authToken = try await authManager.getTokenString(fetchBeforeExpiry: forceFetchAuthToken)
        // }
        return try await networkManager.load(request, with: authToken)
    }
    
    /// - parameter forceFetchAuthTokenIfApplicable: Only forces the auth token to be fetched again if the request requires authentication
    func load<T>(
        _ request: any NetworkRequest<T>,
        forceRefreshAuthTokenIfApplicable: Bool = false
    ) async throws(NetworkError) -> T {
        var authToken: String?
        // if request.requiresAuth {
        //     authToken = try await authManager.getTokenString(fetchBeforeExpiry: forceRefreshAuthTokenIfApplicable)
        // }
        return try await networkManager.load(request, with: authToken)
    }
    
    private static func refreshToken(
        _ tokenRefreshReq: any NetworkRequest<Token>,
        _ networkManager: SimpleNetworkingManager
    ) async -> Result<Token, AuthedNetworkError> {
        do {
            return .success(try await networkManager.load(tokenRefreshReq, with: nil))
        } catch {
            return .failure(.auth(error))
        }
    }
}
