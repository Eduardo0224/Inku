//
//  AuthContainerView.swift
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

struct AuthContainerView: View {

    // MARK: - Properties

    @Bindable var viewModel: AuthViewModel

    // MARK: - States

    @State private var showingRegistration = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if showingRegistration {
                    RegistrationView(
                        viewModel: viewModel,
                        onSwitchToLogin: {
                            withAnimation {
                                showingRegistration = false
                                viewModel.clearForm()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                } else {
                    LoginView(
                        viewModel: viewModel,
                        onSwitchToRegister: {
                            withAnimation {
                                showingRegistration = true
                                viewModel.clearForm()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))
                }
            }
            .toolbar {
                if viewModel.isLoading {
                    ToolbarItem(placement: .cancellationAction) {
                        ProgressView()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AuthContainerView(
        viewModel: AuthViewModel(interactor: MockAuthInteractor())
    )
}
