//
//  AuthedNetworkManager.swift
//
//
//  Created by Samantha Gatt on 6/8/24.
//

import SimpleNetworking

public protocol AuthedNetworkManager<Token>: AnyObject {
    associatedtype Token: AuthToken
    var baseManager: NetworkManager { get }
    var currentToken: Token? { get set }
    var authTask: PatientTask<Result<Token, AuthedNetworkError>> { get }
    init(baseManager: NetworkManager, currentToken: Token?, authTask: PatientTask<Result<Token, AuthedNetworkError>>)
}

public extension AuthedNetworkManager {
    init(
        baseManager: NetworkManager,
        tokenRefreshReq: any NetworkRequest<Token>,
        currentToken: Token? = nil
    ) {
        self.init(baseManager: baseManager, currentToken: currentToken, authTask: PatientTask {
            // TODO: Set current token here so it's not being set every
            await Self.refreshToken(tokenRefreshReq, baseManager)
        })
    }
    
    func update(authToken: Token) {
        // TODO: How to handle if ther's an inflight auth refresh
        currentToken = authToken
        updateKeychain(token: authToken)
    }
    
    func unauthenticate() {
        currentToken = nil
        updateKeychain(token: nil)
    }
    
    /// - parameter forceFetchAuthToken: Forces the auth token to be fetched again even if the request does not require authentication
    func load<T>(
        _ request: any NetworkRequest<T>,
        forceFetchAuthToken: Bool
    ) async throws(NetworkError) -> T {
        var authToken: String?
        if request.requiresAuth || forceFetchAuthToken {
            authToken = await authTask.execute().value?.token
        }
        return try await baseManager.load(request, with: authToken)
    }
    
    /// - parameter forceFetchAuthTokenIfApplicable: Only forces the auth token to be fetched again if the request requires authentication
    func load<T>(
        _ request: any NetworkRequest<T>,
        forceRefreshAuthTokenIfApplicable: Bool = false
    ) async throws(NetworkError) -> T {
        var authToken: String?
        if request.requiresAuth {
            authToken = await authTask.execute().value?.token
        }
        return try await baseManager.load(request, with: authToken)
    }
}

private extension AuthedNetworkManager {
    static func refreshToken(
        _ tokenRefreshReq: any NetworkRequest<Token>,
        _ networkManager: SimpleNetworkingManager
    ) async -> Result<Token, AuthedNetworkError> {
        do {
            return .success(try await networkManager.load(tokenRefreshReq, with: nil))
        } catch {
            return .failure(.auth(error))
        }
    }
    
    func updateKeychain(token: Token?) {
        // TODO: Add token to keychain (or some customizable storage - dependency injection)
    }
}

extension Result {
    var value: Success? { try? get() }
}
