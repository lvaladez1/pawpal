//
//  NotificationsView.swift
//  PawPal
//
//  Created by Claudia Fierro on 6/17/26
//

// TODO for future team:
// Replace mock notification data with Firestore notifications collection.
// Possible triggers:
// - new nearby lost pet reports
// - sighting submissions
// - messages from users
// - report status changes

import SwiftUI

struct NotificationsView: View {
    
    @State private var notifications: [AppNotification] = [
        AppNotification(
            title: "Possible Sighting",
            message: "Possible sighting reported for Bella",
            isRead: false
        ),
        AppNotification(
            title: "Lost Pet Nearby",
            message: "Bella has been reported lost in your area.",
            isRead: false
        ),
        AppNotification(
            title: "You have a message",
            message: "Hi, I found Bella! She is safe. Here is my address. :)",
            isRead: false
        )
    ]
    
    var body: some View {
        ScrollView {
            
            HStack{
                Spacer()
                Button {
                    for index in notifications.indices {
                        notifications[index].isRead = true
                    }
                } label: {
                    Text("Mark all as read")
                        .font(.caption)
                        .foregroundColor(Color.theme.babyBlue)
                }
                .padding(.horizontal)
            }
            LazyVStack(spacing: 16) {
                ForEach($notifications) { $notification in
                    
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(notification.isRead ? .gray : .blue)
                            .frame(width: 12, height: 12)
                            .padding(.top, 6)
                            .onTapGesture {
                                notification.isRead.toggle()
                            }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(notification.title)
                                .font(.headline)

                            Text(notification.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        notification.isRead = true
                    }
                }
            }
            .padding(.top)
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
