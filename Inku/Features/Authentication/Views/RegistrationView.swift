//
//  RegistrationView.swift
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

struct RegistrationView: View {

    // MARK: - Properties

    @Bindable var viewModel: AuthViewModel
    let onSwitchToLogin: () -> Void

    // MARK: - States

    @FocusState private var focusedField: Field?

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: InkuSpacing.spacing32) {
                headerSection

                formSection

                actionButton

                switchPrompt
            }
            .padding(InkuSpacing.spacing24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.inkuSurface)
        .alert(
            L10n.Error.title,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button(L10n.Common.ok, role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Private Views

    private var headerSection: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Image(systemName: "person.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(Color.inkuAccent)
                .padding(.top, InkuSpacing.spacing32)

            Text(L10n.Authentication.Register.title)
                .font(.inkuBody)
                .fontWeight(.bold)

            Text(L10n.Authentication.Register.subtitle)
                .font(.inkuBody)
                .foregroundStyle(Color.inkuTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formSection: some View {
        VStack(spacing: InkuSpacing.spacing16) {
            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(L10n.Authentication.emailLabel)
                    .font(.inkuSubheadline)
                    .fontWeight(.medium)

                TextField(L10n.Authentication.emailLabel, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .padding(InkuSpacing.spacing12)
                    .background(Color.inkuSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .overlay {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .stroke(Color.inkuTextTertiary.opacity(0.2), lineWidth: 1)
                    }
            }

            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(L10n.Authentication.passwordLabel)
                    .font(.inkuSubheadline)
                    .fontWeight(.medium)

                SecureField(L10n.Authentication.passwordLabel, text: $viewModel.password)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await viewModel.register()
                        }
                    }
                    .padding(InkuSpacing.spacing12)
                    .background(Color.inkuSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .overlay {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .stroke(Color.inkuTextTertiary.opacity(0.2), lineWidth: 1)
                    }

                Text(L10n.Authentication.Validation.passwordRequirement)
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuTextSecondary)
            }
        }
    }

    private var actionButton: some View {
        Button {
            Task {
                await viewModel.register()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.inkuTextOnAccent)
            } else {
                Text(L10n.Authentication.Register.button)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuTextOnAccent)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(viewModel.isFormValid ? Color.inkuAccent : Color.inkuTextTertiary)
        .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    private var switchPrompt: some View {
        HStack(spacing: InkuSpacing.spacing8) {
            Text(L10n.Authentication.Prompt.hasAccount)
                .font(.inkuBody)
                .foregroundStyle(Color.inkuTextSecondary)

            Button {
                onSwitchToLogin()
            } label: {
                Text(L10n.Authentication.Prompt.signIn)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuAccent)
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Field

extension RegistrationView {
    enum Field: Hashable {
        case email
        case password
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegistrationView(
            viewModel: AuthViewModel(interactor: MockAuthInteractor()),
            onSwitchToLogin: {}
        )
    }
}
