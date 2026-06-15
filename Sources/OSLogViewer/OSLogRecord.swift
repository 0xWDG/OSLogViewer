//
//  OSLogRecord.swift
//  OSLogViewer
//
//  Created by OpenAI Codex on 14/06/2026.
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

import Foundation

#if canImport(OSLog)
@preconcurrency import OSLog

/// An immutable, concurrency-safe snapshot of an OSLog entry.
public struct OSLogRecord: Identifiable, Sendable {
    /// A stable identifier within one fetched archive.
    public struct RecordID: Hashable, Sendable {
        /// Date the entry was logged.
        public let date: Date

        /// Position of the entry in the fetched archive.
        public let sequence: Int

        /// Creates a record identifier.
        public init(date: Date, sequence: Int) {
            self.date = date
            self.sequence = sequence
        }
    }

    /// Supported OSLog levels.
    public enum Level: Sendable {
        case undefined
        case debug
        case info
        case notice
        case error
        case fault
    }

    /// Record identifier.
    public let id: RecordID

    /// Date the entry was logged.
    public let date: Date

    /// Log level.
    public let level: Level

    /// Formatted log message.
    public let composedMessage: String

    /// Process or framework that sent the entry.
    public let sender: String

    /// Entry subsystem.
    public let subsystem: String

    /// Entry category.
    public let category: String

    init(entry: OSLogEntryLog, sequence: Int) {
        id = RecordID(date: entry.date, sequence: sequence)
        date = entry.date
        level = Level(entry.level)
        composedMessage = entry.composedMessage
        sender = entry.sender
        subsystem = entry.subsystem
        category = entry.category
    }

    init(
        id: RecordID,
        date: Date,
        level: Level,
        composedMessage: String,
        sender: String,
        subsystem: String,
        category: String
    ) {
        self.id = id
        self.date = date
        self.level = level
        self.composedMessage = composedMessage
        self.sender = sender
        self.subsystem = subsystem
        self.category = category
    }
}

private extension OSLogRecord.Level {
    init(_ level: OSLogEntryLog.Level) {
        switch level {
        case .undefined:
            self = .undefined
        case .debug:
            self = .debug
        case .info:
            self = .info
        case .notice:
            self = .notice
        case .error:
            self = .error
        case .fault:
            self = .fault
        default:
            self = .undefined
        }
    }
}
#endif
