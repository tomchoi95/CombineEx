//
//  SignUpForm.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import SwiftUI

class SignUpFormViewModel: ObservableObject {
    // Input
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordComfirmation: String = ""
    
    // Output
    @Published var isValid: Bool = false
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    
    
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
                Text("")
                    .foregroundStyle(.red)
            }
            
            Section {
                SecureField("Password", text: $viewModel.password)
                SecureField("Password Comfirmation", text: $viewModel.passwordComfirmation)
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
