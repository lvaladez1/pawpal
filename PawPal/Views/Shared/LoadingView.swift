//
//  LoadingView.swift
//  PawPal
//
//  Created by Moe Karaki on 11/23/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var showText = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Animated logo
                PawPalLogo(size: 150, showText: false)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Text that appears after a delay
                if showText {
                    VStack(spacing: 12) {
                        Text("PawPal")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Reuniting Hearts & Paws")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Loading...")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.gray)
                            .opacity(fadeIn ? 1.0 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: fadeIn
                            )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            isAnimating = true
            
            // Show text after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showText = true
                }
            }
            
            // Start loading text animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                fadeIn = true
            }
        }
    }
}

#Preview {
    LoadingView()
}