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
        // 두 조건의 합?을 isValid에 저장.
        Publishers.CombineLatest(isUsernameMeetingAtleastThreePublisher, isPasswordSamePublisher)
            .map { $0 && $1 }
            .sink { [weak self] isValid in
                self?.isValid = isValid
            }
            .store(in: &cancellables)
            
        // 비밀번호 검증 메시지 설정
        Publishers.CombineLatest($password, $passwordConfirmation)
            .map { password, confirmation in
                if password.isEmpty && confirmation.isEmpty {
                    return ""
                } else if password.count < 3 {
                    return "비밀번호는 3자 이상이어야 합니다."
                } else if password != confirmation {
                    return "비밀번호가 일치하지 않습니다."
                } else {
                    return ""
                }
            }
            .assign(to: &$passwordMessage)
            
        // 사용자 이름 검증 메시지 설정
        $userName
            .map { username in
                if username.isEmpty {
                    return ""
                } else if username.count < 3 {
                    return "사용자 이름은 3자 이상이어야 합니다."
                } else {
                    return ""
                }
            }
            .assign(to: &$userNameMessage)
    }
    
    private var isUsernameMeetingAtleastThreePublisher: AnyPublisher<Bool, Never> {
        // To activate the button, all conditions must be met.
        // userName. at least 3 charactor.
        $userName // 3개 이상을 만족하는지 Bool값을 publishing 합니다~
            .map { $0.count >= 3 }
            // 여기
            .eraseToAnyPublisher()
        
    }
    
    private var isPasswordSamePublisher: AnyPublisher<Bool, Never> {
        // 비밀번호가 3자리 이상이고, 확인과 일치하는지 확인.
        Publishers.CombineLatest($password, $passwordConfirmation)
            .map { password, confirmation in
                password == confirmation && password.count >= 3
            }
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
            Button("Sign in") {
                print("Singing up as \(viewModel.userName)")
            }
            .disabled(!viewModel.isValid)
        }
    }
    
}

#Preview {
    SignUpForm()
}
