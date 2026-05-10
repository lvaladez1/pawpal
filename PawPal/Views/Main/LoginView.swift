//
//  LoginViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modfied by Moe Karaki on 7/15/25
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var navigateToProfileSetup = false
    @State private var navigateToMainApp = false
    @State private var navigateToRegister = false
    @State private var logoScale = 0.8
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                VStack {
                    if showContent {
                        Spacer()
                        
                        PawPalLogo(size: 100, showText: true)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                        .padding(.horizontal, 30)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                        
                        Button(action: login) {
                            Text("Login")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.babyBlue)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 30)
                        
                        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                            handleGoogleSignIn()
                        }
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                        .frame(height: 50)
                        .padding(.top, 10)
                        .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        HStack {
                            Text("Don't have an account?")
                            Button(action: { navigateToRegister = true }) {
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(.theme.babyBlue)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showContent = true
                    }
                }
                .navigationDestination(isPresented: $navigateToMainApp) {
                    MainTabView()
                }
                .navigationDestination(isPresented: $navigateToProfileSetup) {
                    EnterProfileView()
                }
                .navigationDestination(isPresented: $navigateToRegister) {
                    RegisterView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email or password field is empty."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            checkUserProfileExists()
        }
    }

    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase clientID is missing."
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let idToken = result?.user.idToken?.tokenString,
                  let accessToken = result?.user.accessToken.tokenString else {
                errorMessage = "Missing Google ID tokens."
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                checkUserProfileExists()
            }
        }
    }

    private func checkUserProfileExists() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection(FS.Users.collection).document(userId).getDocument { document, error in
            if let error = error {
                errorMessage = "Failed to load profile: \(error.localizedDescription)"
                return
            }

            if let document = document, document.exists {
                navigateToMainApp = true
            } else {
                navigateToProfileSetup = true
            }
        }
    }
}

#Preview {
    LoginView()
}
