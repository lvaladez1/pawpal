import SwiftUI
import UIKit

extension Color {
    struct Theme {
        let babyBlue = Color(red: 0.53, green: 0.81, blue: 0.92)
        let babyBlueLight = Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)
        let themeBackground = Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)
        let secondaryText = Color.gray
    }
    
    static let theme = Theme()
    
    // Also keep direct access for backwards compatibility
    static let babyBlue = Color(red: 0.53, green: 0.81, blue: 0.92)
    static let themeBackground = Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)
    static let babyBlueLight = Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)
}

extension UIColor {
    struct Theme {
        static let babyBlue = UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)
        static let lightBabyBlue = UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0)
    }
    
    static let theme = Theme()
}
