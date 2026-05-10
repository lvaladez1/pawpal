//
//  WelcomeView.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modified by Moe Karaki on 7/18/25.
//  Rewritten for layout consistency across all device sizes (
//

import SwiftUI

struct WelcomeView: View {
    @State private var logoScale = 0.8
    @State private var textOpacity = 0.0
    @State private var buttonScale = 0.9
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1), // Baby blue light
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Top flexible space keeps everything centered vertically
                Spacer(minLength: 80)
                
                // Animated logo
                PawPalLogo(size: 140, showText: true)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                            logoScale = 1.0
                        }
                    }
                
                Spacer().frame(height: 32)
                
                // Mission statement
                VStack(spacing: 20) {
                    Text("Helping reunite lost pets with their families.")
                        .font(.title3)
                        .fontWeight(.bold) // Made bolder
                        .foregroundColor(Color(red: 0.53, green: 0.81, blue: 0.92)) // Baby blue text
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .opacity(textOpacity)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Join our community of pet lovers working together to bring every furry friend home safely.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 35)
                        .opacity(textOpacity)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                        textOpacity = 1.0
                    }
                }
                
                Spacer().frame(height: 50)
                
                // Get Started button
                NavigationLink(destination: LoginView()) {
                    HStack(spacing: 10) {
                        Image(systemName: "pawprint.fill") // Changed to pawprint
                            .font(.title3)
                        
                        Text("Get Started")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .frame(height: 56)
                    .background(Color(red: 0.53, green: 0.81, blue: 0.92)) // Baby blue solid
                    .cornerRadius(28)
                    .shadow(color: Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(buttonScale)
                .padding(.horizontal, 40)
                .onAppear {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.6)) {
                        buttonScale = 1.0
                    }
                }
                
                Spacer(minLength: 80)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
