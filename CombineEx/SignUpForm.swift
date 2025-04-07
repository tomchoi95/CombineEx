//
//  SignUpForm.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import SwiftUI
import Combine

class SignUpFormViewModel: ObservableObject {
    // Input
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordComfirmation: String = ""
    
    // Output
    @Published var isValid: Bool = false
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    
    private lazy var isUsernameLengthValidPublisher: AnyPublisher<Bool, Never> = {
        $username
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
    }()
    
    private lazy var isPasswordMatchingPublisher: AnyPublisher<Bool, Never> = {
        Publishers.CombineLatest($password, $passwordComfirmation)
            .map(==)
            .eraseToAnyPublisher()
    }()
    
    init() {
        isUsernameLengthValidPublisher
            .assign(to: &$isValid)
        // assign 은 이미 cancellabe을 만족함.
        isUsernameLengthValidPublisher
            .map { $0 ? "" : "Username too short. Needs to be at least 3 characters." }
            .assign(to: &$usernameMessage)
    }
}

struct SignUpForm: View {
    
    @StateObject var viewModel = SignUpFormViewModel()
    
    var body: some View {
        
        Form {
            Section {
                TextField("Username", text: $viewModel.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } footer: {
                Text(viewModel.usernameMessage)
                    .foregroundStyle(.red)
            }
            
            Section {
                SecureField("Password", text: $viewModel.password)
                SecureField("Password Comfirmation", text: $viewModel.passwordComfirmation)
            } footer: {
                Text(viewModel.passwordMessage)
                    .foregroundStyle(.red)
            }
            
            Section {
                Button("Sign Up") {
                    print("Signing up as \(viewModel.username)")
                }
                
                .disabled(!viewModel.isValid)
            }
        }
    }
}

#Preview {
    SignUpForm()
}
