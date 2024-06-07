//
//  OSLogViewer.Colors.swift
//  OSLogViewer
//
//  Created by Wesley de Groot on 01/06/2024.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

import SwiftUI
import OSLog

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

extension OSLogViewer {
    /// Generate the background color for the log message
    /// - Parameter level: log level
    /// - Returns: The appropiate color
    func getBackgroundColor(level: OSLogEntryLog.Level) -> Color {
        switch level {
        case .undefined, .debug, .info, .notice:
            getBackgroundColorDefault()

        case .error:
            getBackgroundColorError()

        case .fault:
            getBackgroundColorFault()

        default:
            getBackgroundColorDefault()
        }
    }

    /// Get the default background color
    func getBackgroundColorDefault() -> Color {
#if canImport(UIKit)
            Color(uiColor: UIColor.secondarySystemGroupedBackground)
#elseif canImport(AppKit)
            Color(nsColor: .init(name: "debug", dynamicProvider: { traits in
                if traits.name == .darkAqua || traits.name == .vibrantDark {
                    return .init(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    return .init(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                }
            }))
#else
            // Fallback
            Color.white
#endif
    }

    /// Get the error background color
    func getBackgroundColorError() -> Color {
#if canImport(UIKit)
            Color(uiColor: .init(dynamicProvider: { traits in
                if traits.userInterfaceStyle == .light {
                    return .init(red: 1, green: 0.968, blue: 0.898, alpha: 1)
                } else {
                    return .init(red: 0.858, green: 0.717, blue: 0.603, alpha: 0.4)
                }
            }))
#elseif canImport(AppKit)
            Color(nsColor: .init(name: "Error", dynamicProvider: { traits in
                if traits.name == .darkAqua || traits.name == .vibrantDark {
                    return .init(red: 0.858, green: 0.717, blue: 0.603, alpha: 0.4)
                } else {
                    return .init(red: 1, green: 0.968, blue: 0.898, alpha: 1)
                }
            }))
#else
            Color.yellow
#endif
    }

    /// Get the fault background color
    func getBackgroundColorFault() -> Color {
#if canImport(UIKit)
            Color(uiColor: .init(dynamicProvider: { traits in
                if traits.userInterfaceStyle == .light {
                    return .init(red: 0.98, green: 0.90, blue: 0.90, alpha: 1)
                } else {
                    return .init(red: 0.26, green: 0.15, blue: 0.17, alpha: 1)
                }
            }))
#elseif canImport(AppKit)
            Color(nsColor: .init(name: "Fault", dynamicProvider: { traits in
                if traits.name == .darkAqua || traits.name == .vibrantDark {
                    return .init(red: 0.26, green: 0.15, blue: 0.17, alpha: 1)
                } else {
                    return .init(red: 0.98, green: 0.90, blue: 0.90, alpha: 1)
                }
            }))
#else
            Color.red
#endif
    }
}
