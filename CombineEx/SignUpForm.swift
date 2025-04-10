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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 비밀번호가 4자리 이상이고, 서로 일치하니?
        Publishers.CombineLatest(isPasswordMoreThanFourLatters, isPasswordAndConfirmMatching)
            .drop(while: { [weak self] _,_ in
                guard let self = self else { return true }
                return self.password.isEmpty || self.passwordConfirmation.isEmpty
            })
            .map { (isLengthEnough, isMatching) in
                
                switch (isLengthEnough, isMatching) {
                    case (false, false):
                        return "걍 이건 아님"
                    case (true, false):
                        return "비번 불일치"
                    case (false, true):
                        return "길이 불충분"
                    case (true, true):
                        
                        return ""
                }
            }
            .assign(to: &$passwordMessage)
        
    }
    
    // 아이디가 4자리 이상이니?
    private var isUserNameMoreThanFourLetters: AnyPublisher<Bool, Never> {
        $userName
            .map { $0.count >= 4 }
            .eraseToAnyPublisher()
    }
    
    // 비번이 4자리 이상이니?
    private var isPasswordMoreThanFourLatters: AnyPublisher<Bool, Never> {
        $password
            .map { $0.count >= 4 }
            .eraseToAnyPublisher()
    }
    
    // 비밀번호와 비밀번호 확인이 서로 일치하니?
    private var isPasswordAndConfirmMatching: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordConfirmation)
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
            Text(viewModel.userNameMessage)
                .foregroundStyle(.red)
                .frame(height: 20)
        }
    }
    private var passwordSection: some View {
        Section {
            SecureField("Password", text: $viewModel.password)
            SecureField("Password Confirmation", text: $viewModel.passwordConfirmation)
        } footer: {
            Text(viewModel.passwordMessage)
                .foregroundStyle(.red)
                .frame(height: 20)
        }
    }
    private var confirmButton: some View {
        Section {
            Button("Sign up") {
                print("Singing up as \(viewModel.userName)")
            }
            .disabled(!viewModel.isValid)
        }
    }
    
}

#Preview {
    SignUpForm()
}
