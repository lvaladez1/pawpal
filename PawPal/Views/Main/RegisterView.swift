//
//  RegisterView.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modifed by Moe Karaki on 7/18/25.
//
import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var navigateToProfileSetup = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                if showContent {
                    Spacer()
                    
                    PawPalLogo(size: 90, showText: true)
                        .padding(.bottom, 10)
                    
                    Text("Help reunite lost pets with their families")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .padding(.horizontal, 30)
                    }
                    
                    Button(action: register) {
                        Text("Create Account")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.theme.babyBlue, Color.theme.babyBlue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.theme.babyBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button(action: { dismiss() }) {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.theme.babyBlue)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .navigationDestination(isPresented: $navigateToProfileSetup) {
                EnterProfileView()
            }
        }
        .navigationBarHidden(true)
    }

    private func register() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            print("Registration successful for user: \(result?.user.email ?? "No email")")
            navigateToProfileSetup = true
        }
    }
}

#Preview {
    RegisterView()
}
