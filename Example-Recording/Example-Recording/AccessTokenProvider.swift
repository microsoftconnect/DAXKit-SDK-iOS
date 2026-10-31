//
//  AccessTokenProvider.swift
//  Example-Recording
//
//  Created by Ryan LaSante on 5/16/24.
//

import Foundation
import DragonCopilotAmbient

/// Example implementation of an AccessTokenProvider backed by machine-to-machine authentication.
struct MachineToMachineAccessTokenProvider: AccessTokenProvider {
    private let domainURL = URL(string: "https://example.com/oauth/token")
    private let clientId = "ClientId"
    private let clientSecret = "ClientSecret"
    private let audience = "AuthAudience"

    /// Ambient calls this function whenever it requires an authentication token.
    /// This can be called multiple times per upload if there are network disconnects.
    func accessToken(
        onSuccess: @escaping @Sendable (String, Date) -> Void,
        onError: @escaping @Sendable (Error) -> Void
    ) {
        guard let domainURL else {
            onError(TokenProviderError.invalidResponse)
            return
        }

        Task.detached {
            do {
                let uploadParams: [String: String] = [
                    "grant_type": "client_credentials",
                    "client_id": clientId,
                    "client_secret": clientSecret,
                    "audience": audience,
                ]
                var request = URLRequest(url: domainURL)
                request.httpMethod = "POST"
                request.httpBody = try JSONEncoder().encode(uploadParams)
                request.setValue("application/json", forHTTPHeaderField: "content-type")
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw TokenProviderError.requestFailed
                }
                let token = try Self.tokenResponse(from: data)
                onSuccess(token.value, Date().addingTimeInterval(token.expiresIn))
            } catch {
                onError(error)
            }
        }
    }

    static func tokenResponse(from data: Data) throws -> (value: String, expiresIn: TimeInterval) {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = json["access_token"] as? String,
            !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let expiresIn = (json["expires_in"] as? NSNumber)?.doubleValue,
            expiresIn.isFinite,
            expiresIn > 0
        else {
            throw TokenProviderError.invalidResponse
        }
        return (accessToken, expiresIn)
    }
}

private enum TokenProviderError: Error {
    case requestFailed
    case invalidResponse
}
