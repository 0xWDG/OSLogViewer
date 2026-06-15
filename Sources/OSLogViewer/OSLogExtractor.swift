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
@preconcurrency import OSLog
#endif

/// Extracts the current process's OSLog history.
public final class OSLogExtractor: Identifiable, Sendable {
    /// Identifier
    public let id = UUID()

    /// Subsystem to read logs from
    public let subsystem: String

    /// Date from which logs should be read.
    public let since: Date

    /// Creates an OSLog extractor.
    ///
    /// - Parameters:
    ///   - subsystem: Subsystem to read.
    ///   - since: Date from which logs should be read. Defaults to one hour ago.
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
        OSLogArchive.make(records: await records())
#else
        return ""
#endif
    }

#if canImport(OSLog)
    /// Get immutable, concurrency-safe log records.
    public func records() async -> [OSLogRecord] {
        do {
            return try await loadRecords()
        } catch {
            os_log(.fault, "Something went wrong %@", error as NSError)
            return []
        }
    }

    /// Loads immutable, concurrency-safe log records.
    public func loadRecords() async throws -> [OSLogRecord] {
        try await OSLogLoader.records(
            subsystem: subsystem,
            since: since
        )
    }

    /// Gets raw OSLog entries.
    @available(*, deprecated, message: "Use records() to receive concurrency-safe values.")
    public func getLog() async -> [OSLogEntryLog] {
        do {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let position = logStore.position(date: since)
            let predicate = NSPredicate(format: "subsystem BEGINSWITH %@", subsystem)

            return try logStore.getEntries(
                at: position,
                matching: predicate
            ).compactMap { $0 as? OSLogEntryLog }
        } catch {
            os_log(.fault, "Something went wrong %@", error as NSError)
            return []
        }
    }
#endif
}
