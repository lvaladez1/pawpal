//
//  MainTabView.swift
//  PawPal
//
//  Created by Juan Zavala on 8/17/25.
//
//  This view is the main tab bar container shown after the user successfully logs in.
//  It holds the three primary sections of the app: Browse (LostPetsView),
//  Map (LostPetMapView), and Report (LostPetReportView).
//  A logout button is provided in the navigation bar of the Browse tab.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    
    // Inject global authentication state.
    // This allows this view (and others) to call `authVM.signOut()`
    // which cleanly logs out the user and resets the app's root view.
    @EnvironmentObject var authVM: AuthViewModel

    //Don't think we need this anymore
    @Environment(\.dismiss) var dismiss
    
    init() {
        // Customizing the Tab Bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = .clear // Remove top line
        
        // Active item color
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.systemGray3
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray3]
        
        itemAppearance.selected.iconColor = UIColor.Theme.babyBlue // Baby Blue
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.Theme.babyBlue]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {

            // Browse Tab (Lost Pets List)
            NavigationStack {
                LostPetsView()
            }
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            
            NavigationStack {
                LostPetReportView()
            }
            .tabItem {
                Label("Report", systemImage: "plus.circle")
            }
            
            NavigationStack{
                UserProfileView()
            }.tabItem {
                Label("Profile", systemImage: "person")
            }
        }
      
    }
}

#Preview {
    MainTabView()
}
