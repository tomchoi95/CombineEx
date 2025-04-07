//
//  SignUpForm.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import SwiftUI
import Combine


class SignUpFormViewModel: ObservableObject {
    
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    
    @Published var userNameMessage: String = ""
    @Published var passwordMessage: String = ""
    @Published var isValid: Bool = false
    
//    private var cancellables = Set<AnyCancellable>()
    
    private var isUsernameMeetingAtleastThreePublisher: AnyPublisher<Bool, Never> {
        // To activate the button, all conditions must be met.
        // userName. at least 3 charactor.
        $userName // 3개 이상을 만족하는지 Bool값을 publishing 합니다~
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
        
    }
    
    private var isPasswordSamePublisher: AnyPublisher<Bool, Never> {
        $password // 비밀번호가 일치하는지 Bool값을 publishing 합니다.
            .combineLatest($passwordConfirmation)
            .map(==)
            .eraseToAnyPublisher()
    }
    
}

struct SignUpForm: View {
    
    @StateObject private var viewModel = SignUpFormViewModel()
    
    var body: some View {
        Form {
            idSection
            passwordSection
            confirmButton
        }
    }
    
    private var idSection: some View {
        Section {
            TextField("Username", text: $viewModel.userName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        } footer: {
            Text(verbatim: viewModel.userNameMessage)
                .foregroundStyle(.red)
        }
    }
    private var passwordSection: some View {
        Section {
            SecureField("Password", text: $viewModel.password)
            SecureField("Password Confirmation", text: $viewModel.passwordConfirmation)
        } footer: {
            Text(viewModel.passwordMessage)
                .foregroundStyle(.red)
        }
    }
    private var confirmButton: some View {
        Section {
            Button("Sign in?") {
                print("Singing up as \(viewModel.userName)")
            }
            .disabled(!viewModel.isValid)
        }
    }
    
}

#Preview {
    SignUpForm()
}
