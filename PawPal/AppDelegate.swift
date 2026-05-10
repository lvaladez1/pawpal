//
//  AppDelegate.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//

import Firebase
import FirebaseCore
import GoogleSignIn
import UIKit
import UserNotifications  // Added for notifications

class AppDelegate: UIResponder, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        // Set the notification center delegate so alerts are shown even in foreground
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // Handle Google Sign-In URL
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Allow notifications to display while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {

        return [.banner, .sound, .badge]
    }
}
