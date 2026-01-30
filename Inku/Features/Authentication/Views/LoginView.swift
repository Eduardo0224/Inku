//
//  LoginView.swift
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

struct LoginView<T: AuthViewModelProtocol>: View {

    // MARK: - Properties

    @Bindable var viewModel: T
    let onSwitchToRegister: () -> Void

    // MARK: - States

    @FocusState private var focusedField: Field?

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

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
        .onChange(of: viewModel.authState) { _, newValue in
            if case .authenticated = newValue {
                dismiss()
            }
        }
    }

    // MARK: - Private Views

    private var headerSection: some View {
        VStack(spacing: InkuSpacing.spacing12) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.inkuAccent)
                .padding(.top, InkuSpacing.spacing32)

            Text(L10n.Authentication.Login.title)
                .font(.inkuBody)
                .fontWeight(.bold)

            Text(L10n.Authentication.Login.subtitle)
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
                    .disabled(viewModel.isLoading)
            }

            VStack(alignment: .leading, spacing: InkuSpacing.spacing8) {
                Text(L10n.Authentication.passwordLabel)
                    .font(.inkuSubheadline)
                    .fontWeight(.medium)

                SecureField(L10n.Authentication.passwordLabel, text: $viewModel.password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .padding(InkuSpacing.spacing12)
                    .background(Color.inkuSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: InkuRadius.radius12))
                    .overlay {
                        RoundedRectangle(cornerRadius: InkuRadius.radius12)
                            .stroke(Color.inkuTextTertiary.opacity(0.2), lineWidth: 1)
                    }
                    .disabled(viewModel.isLoading)

                Text(L10n.Authentication.Validation.passwordRequirement)
                    .font(.inkuCaption)
                    .foregroundStyle(Color.inkuTextSecondary)
            }
        }
    }

    private var actionButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.inkuTextOnAccent)
            } else {
                Text(L10n.Authentication.Login.button)
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
            Text(L10n.Authentication.Prompt.noAccount)
                .font(.inkuBody)
                .foregroundStyle(Color.inkuTextSecondary)

            Button {
                onSwitchToRegister()
            } label: {
                Text(L10n.Authentication.Prompt.signUp)
                    .font(.inkuBody)
                    .foregroundStyle(Color.inkuAccent)
                    .fontWeight(.semibold)
            }
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Field

extension LoginView {
    enum Field: Hashable {
        case email
        case password
    }
}

// MARK: - Preview

#Preview {
    LoginView(
        viewModel: AuthViewModel(interactor: MockAuthInteractor()),
        onSwitchToRegister: {}
    )
}
