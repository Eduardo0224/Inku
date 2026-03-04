//
//  SSLPinningDelegate.swift
//  Inku
//
//  Created by Eduardo Andrade on 04/03/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Foundation
import CryptoKit
import os

/// URLSession delegate that implements SSL Certificate Pinning
/// Validates the server's public key hash against a set of known hashes
final class SSLPinningDelegate: NSObject, URLSessionDelegate, Sendable {

    // MARK: - Private Properties

    /// SHA-256 hashes of trusted server public keys
    private let pinnedHashes: Set<String>

    /// Whether pinning is enabled (can be disabled for testing)
    private let isPinningEnabled: Bool

    // MARK: - Initializers

    init(pinnedHashes: Set<String>, isPinningEnabled: Bool = true) {
        self.pinnedHashes = pinnedHashes
        self.isPinningEnabled = isPinningEnabled
        super.init()
    }

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard isPinningEnabled else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let serverCertificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = serverCertificate.first else {
            Logger.core.error("SSL Pinning: No server certificate found")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract public key data and compute SHA-256 hash
        let serverPublicKeyData = SecCertificateCopyKey(certificate)
        guard let publicKeyData = serverPublicKeyData,
              let publicKeyExternalRepresentation = SecKeyCopyExternalRepresentation(publicKeyData, nil) as? Data else {
            Logger.core.error("SSL Pinning: Failed to extract public key")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverHash = SHA256.hash(data: publicKeyExternalRepresentation)
            .compactMap { String(format: "%02x", $0) }
            .joined()

        if pinnedHashes.contains(serverHash) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            Logger.core.warning("SSL Pinning: Server public key hash mismatch")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
