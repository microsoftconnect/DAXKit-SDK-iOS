//
//  AccessTokenProvider.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import Foundation
import DAXKit
import JWTDecode

/// Example implementation of an AccessTokenProvider backed by machine-to-machine authentication.
final class Machine2MachineAccessTokenProvider: NSObject, AccessTokenProvider {
    let domainURL = "https://nuancehdpdev.auth0.com/oauth/token"
    let client_id = "ClientId"
    let secret = "ClientSecret"
    let audience = "AuthAudience"

    /// DAXKit calls this function whenever it requires an authentication token to talk to its servers.
    /// This can be called multiple times per upload if there are network disconnects.
    /// Ideally, your app should do the following:
    /// * Cache the token locally
    /// * Check to see if it is still valid when DAXKit requests a new token
    /// If the token is invalid then it should be refreshed by your application.
    func accessToken(
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        guard let url = URL(string: domainURL) else {
            fatalError("Invalid authentication domain URL")
        }
        Task {
            do {
                let uploadParams: [String: String] = [
                    "grant_type": "client_credentials",
                    "client_id": client_id,
                    "client_secret": secret,
                    "audience": audience,
                ]
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = try JSONEncoder().encode(uploadParams)
                request.setValue("application/json", forHTTPHeaderField: "content-type")
                let (data, _) = try await URLSession.shared.data(for: request)
                let accessToken = try Self.accessToken(from: data)
                onSuccess(accessToken)
            } catch {
                print("\(Date().ISO8601Format()) Failed to get data from access token request.")
                onFailure(error)
            }
        }
    }

    private static func accessToken(from data: Data) throws -> String {
        // Validate that the data returned contains an access token.
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = json["access_token"] as? String
        else {
            print("\(Date().ISO8601Format())No valid access token returned")
            throw AccessTokenProviderError.refreshFailed
        }
        // Ensure the token hasn't expired.
        guard
            let jwt = try? decode(jwt: accessToken),
            !jwt.expired
        else {
            print("Received access token has expired")
            throw AccessTokenProviderError.refreshFailed
        }
        return accessToken
    }
}
