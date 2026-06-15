//
//  OSLogArchive.swift
//  OSLogViewer
//
//  Created by OpenAI Codex on 14/06/2026.
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

import Foundation

#if canImport(OSLog)
@preconcurrency import OSLog

enum OSLogLoader {
    static func records(subsystem: String, since: Date) async throws -> [OSLogRecord] {
        try await Task.detached(priority: .utility) {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let position = logStore.position(date: since)
            let predicate = NSPredicate(format: "subsystem BEGINSWITH %@", subsystem)
            let entries = try logStore.getEntries(
                at: position,
                matching: predicate
            )
            var records: [OSLogRecord] = []

            for entry in entries {
                guard let entry = entry as? OSLogEntryLog else {
                    continue
                }

                records.append(
                    OSLogRecord(entry: entry, sequence: records.count)
                )
            }

            return records
        }
        .value
    }
}

enum OSLogArchive {
    static func make(
        records: [OSLogRecord],
        appName: String = applicationName,
        generatedAt: Date = .now
    ) -> String {
        var archive = "This is the OSLog archive for \(appName).\r\n"
        archive.append("Generated on \(generatedAt.formatted())\r\n")
        archive.append("Generator https://github.com/0xWDG/OSLogViewer\r\n\r\n")

        for (index, record) in records.enumerated() {
            if index > 0 {
                archive.append("\r\n\r\n")
            }

            archive.append(record.composedMessage)
            archive.append("\r\n")
            archive.append(record.level.emoji)
            archive.append(" \(record.date.formatted())")
            archive.append(" 🏛️ \(record.sender)")
            archive.append(" ⚙️ \(record.subsystem)")
            archive.append(" 🌐 \(record.category)")
        }

        return archive
    }

    private static var applicationName: String {
        if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            displayName
        } else if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            name
        } else {
            "this application"
        }
    }
}

extension OSLogRecord.Level {
    var emoji: String {
        switch self {
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
        }
    }
}
#endif
