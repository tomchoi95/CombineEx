//
//  SignUpForm.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-07.
//

import SwiftUI

class SignUpFormViewModel: ObservableObject {
    @Published var username: String = ""
}

struct SignUpForm: View {
    
    @StateObject var viewModel = SignUpFormViewModel()
    
    var body: some View {
        
        Form {
            Section {
                TextField("Username", text: <#Binding<String>#>)
            } footer: {
                Text("")
                    .foregroundStyle(.red)
            }
            
            Section {
                SecureField("Username", text: <#Binding<String>#>)
                SecureField("Username", text: <#Binding<String>#>)
            }
            
            Section {
                Button("Sign Up") {
                    print("Signing up as ")
                }
                .disabled(<#T##disabled: Bool##Bool#>)
            }
        }
    }
}

#Preview {
    SignUpForm()
}
