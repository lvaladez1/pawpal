//
//  Notifications.swift
//  PawPal
//
//  Created by Claudia Fierro on 6/17/26.
//

import Foundation

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    var isRead: Bool
}
