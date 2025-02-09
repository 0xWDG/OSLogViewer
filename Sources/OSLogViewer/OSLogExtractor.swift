//
//  OSLogExtractor.swift
//  OSLogViewer
//
//  Created by Wesley de Groot on 19/11/2024.
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

import Foundation

#if canImport(OSLog)
import OSLog
#endif

/// OSLogExtractor is made to extract your apps OS_Log history,
public class OSLogExtractor {
    /// Identifier
    public let id = UUID()

    /// Subsystem to read logs from
    public var subsystem: String

    /// From which date preriod
    public var since: Date

    /// OSLogExtractor is made to extract your apps OS_Log history,
    ///
    /// - Parameters:
    ///   - subsystem: which subsystem should be read
    ///   - since: from which time (standard 1hr)
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "",
        since: Date = Date().addingTimeInterval(-3600)
    ) {
        self.subsystem = subsystem
        self.since = since
    }

    /// Export OSLog as string.
    public func export() async -> String {
#if canImport(OSLog)
        let logMessages = await getLog()

        let appName: String = {
            if let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                return displayName
            } else if let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                return name
            }
            return "this application"
        }()

        return [
            "This is the OSLog archive for \(appName).\r\n",
            "Generated on \(Date().formatted())\r\n",
            "Generator https://github.com/0xWDG/OSLogViewer\r\n\r\n",
            logMessages.map {
                "\($0.composedMessage)\r\n" +
                getLogLevelEmoji(level: $0.level) +
                " \($0.date.formatted()) 🏛️ \($0.sender) ⚙️ \($0.subsystem) 🌐 \($0.category)"
            }
                .joined(separator: "\r\n\r\n")
        ]
            .joined()
#else
        return ""
#endif
    }

#if canImport(OSLog)
    /// Generate an emoji for the current log level
    /// - Parameter level: log level
    /// - Returns: Emoji
    func getLogLevelEmoji(level: OSLogEntryLog.Level) -> String {
        switch level {
        case .undefined, .notice:
            "🔔"
        case .debug:
            "🩺"
        case .info:
            "ℹ️"
        case .error:
            "❗"
        case .fault:
            "‼️"
        default:
            "🔔"
        }
    }

    /// Get the logs
    public func getLog() async -> [OSLogEntryLog] {
        do {
            /// Initialize logstore for the current proces
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)

            /// Fetch all logs since a specific date
            let sinceDate = logStore.position(date: self.since)

            /// Predicate (filter) all results to have the subsystem starting with the given subsystem
            let predicate = NSPredicate(
                format: "subsystem BEGINSWITH %@",
                self.subsystem
            )

            /// Get all logs from the log store
            return try logStore.getEntries(
                at: sinceDate,
                matching: predicate
            ).compactMap {
                // Remap from `AnySequence<OSLogEntry>` to type `[OSLogEntryLog]`
                $0 as? OSLogEntryLog
            }

        } catch {
            // We fail to get the results, add this to the log.
            os_log(.fault, "Something went wrong %@", error as NSError)

            return []
        }
    }
#endif
}
