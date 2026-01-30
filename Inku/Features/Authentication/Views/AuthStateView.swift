//
//  AuthStateView.swift
//  Inku
//
//  Created by Eduardo Andrade on 30/01/26.
//
//  Swift Developer Program (SDP26) - Otoño 2025
//  Apple Coding Academy
//
//  For educational purposes only.
//  Copyright © 2025 Eduardo Andrade. All rights reserved.
//

import SwiftUI
import InkuUI

struct AuthStateView<Content: View>: View {

    // MARK: - Properties

    @State private var viewModel: AuthViewModel
    let content: Content

    // MARK: - Initializers

    init(
        interactor: AuthInteractorProtocol = AuthInteractor(),
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = AuthViewModel(interactor: interactor)
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.authState {
            case .unauthenticated:
                AuthContainerView(viewModel: viewModel)

            case .authenticated:
                content

            case .loading:
                loadingView
            }
        }
        .task {
            await viewModel.checkAuthenticationStatus()
        }
    }

    // MARK: - Private Views

    private var loadingView: some View {
        ZStack {
            Color.inkuSurface
                .ignoresSafeArea()

            VStack(spacing: InkuSpacing.spacing16) {
                ProgressView()
                    .tint(.inkuAccent)

                Text(L10n.Common.loading)
                    .foregroundStyle(Color.inkuTextSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Unauthenticated") {
    AuthStateView(interactor: MockAuthInteractor()) {
        Text("Authenticated Content")
    }
}

#Preview("Authenticated") {
    let interactor = MockAuthInteractor()
    let viewModel = AuthViewModel(interactor: interactor)

    AuthStateView(interactor: interactor) {
        VStack {
            Text("Authenticated Content")
                .font(.inkuBody)

            Button("Logout") {
                Task {
                    await viewModel.logout()
                }
            }
        }
    }
    .task {
        await viewModel.login()
    }
}
