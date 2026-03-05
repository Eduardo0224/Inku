//
//  SSLPinningDelegateTests.swift
//  InkuTests
//
//  Created by Eduardo Andrade on 04/03/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2026 Eduardo Andrade. All rights reserved.
//

import Testing
import Foundation
import Security
@testable import Inku

@Suite("SSLPinningDelegate Tests")
struct SSLPinningDelegateTests {

    // MARK: - Behavior Tests

    @Test("When pinning is disabled, should use default handling")
    func pinningDisabledUsesDefaultHandling() {
        // Given
        let delegate = SSLPinningDelegate(pinnedHashes: [], isPinningEnabled: false)
        var receivedDisposition: URLSession.AuthChallengeDisposition?
        var receivedCredential: URLCredential?
        let protectionSpace = Self.makeProtectionSpace(authenticationMethod: NSURLAuthenticationMethodServerTrust)
        let challenge = Self.makeAChallenge(protectionSpace: protectionSpace)
        // When
        delegate.urlSession(
            URLSession.shared,
            didReceive: challenge
        ) { disposition, credential in
            receivedDisposition = disposition
            receivedCredential = credential
        }
        // Then
        #expect(receivedDisposition == .performDefaultHandling)
        #expect(receivedCredential == nil)
    }

    @Test("When authentication method is not server trust, should cancel challenge")
    func nonServerTrustAuthMethodCancelsChallenge() {
        // Given
        let delegate = SSLPinningDelegate(pinnedHashes: ["test_hash"], isPinningEnabled: true)
        var receivedDisposition: URLSession.AuthChallengeDisposition?
        let protectionSpace = Self.makeProtectionSpace(authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        let challenge = Self.makeAChallenge(protectionSpace: protectionSpace)
        // When
        delegate.urlSession(
            URLSession.shared,
            didReceive: challenge
        ) { disposition, credential in
            receivedDisposition = disposition
        }
        // Then
        #expect(receivedDisposition == .cancelAuthenticationChallenge)
    }

    // MARK: - Integration Note
    //
    // Full SSL pinning validation with real certificates requires:
    // 1. A test server with a known certificate
    // 2. The ability to extract the public key hash from that certificate
    // 3. Network access during tests
    //
    // These tests focus on:
    // - Behavior when pinning is disabled
    // - Handling of invalid authentication methods
    //
    // Production SSL pinning validation should be tested through:
    // - Integration tests with a controlled test server
    // - Manual testing during development
    // - Monitoring of SSL pinning failures in production logs
}

// MARK: - Test Data

private extension SSLPinningDelegateTests {

    static func makeProtectionSpace(
        authenticationMethod: String
    ) -> URLProtectionSpace {
        .init(
            host: "test.inku.com",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: authenticationMethod
        )
    }

    static func makeAChallenge(
        protectionSpace: URLProtectionSpace
    ) -> URLAuthenticationChallenge {
        .init(
            protectionSpace: protectionSpace,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: MockAuthChallengeSender()
        )
    }
}

// MARK: - Mock Auth Challenge Sender

private final class MockAuthChallengeSender: NSObject, URLAuthenticationChallengeSender {

    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) { }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) { }

    func cancel(_ challenge: URLAuthenticationChallenge) { }
}
