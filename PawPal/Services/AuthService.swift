//
//  AuthService.swift
//  PawPal
//
//  Created by Hieu Hoang on 1/5/25.
//

import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}

    func registerUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
