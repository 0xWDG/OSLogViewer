//
//  OSLogViewer.swift
//  OSLogViewer
//
//  Created by Wesley de Groot on 01/06/2024.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

import SwiftUI
import OSLog

/// OSLogViewer
public struct OSLogViewer: View {
    /// Subsystem to read
    public var subsystem: String

    /// From which date preriod
    public var since: Date

    /// OSLogViewer
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

    @State
    private var logMessages: [OSLogEntryLog] = []

    @State
    private var finishedCollecting: Bool = false

    public var body: some View {
        VStack {
            List {
                ForEach(logMessages, id: \.self) { entry in
                    VStack {
                        Text(entry.composedMessage)
                        detailsBuilder(for: entry)
                            .font(.footnote)
                    }
                    .listRowBackground(getBackgroundColor(level: entry.level))
                }
            }
            .navigationTitle("OSLog viewer")
        }
        .overlay {
            if logMessages.isEmpty {
                if !finishedCollecting {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("Collecting logs...", systemImage: "hourglass")
                    } else {
                        VStack {
                            Image(systemName: "hourglass")
                            Text("Collecting logs...")
                        }
                    }
                } else {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No results found",
                            systemImage: "magnifyingglass",
                            description: Text("for subsystem \"\(subsystem)\".")
                        )
                    } else {
                        VStack {
                            Image(systemName: "magnifyingglass")
                            Text("No results found for subsystem \"\(subsystem)\".")
                        }
                    }
                }
            }
        }
        .refreshable {
            await getLog()
        }
        .onAppear {
            Task {
                await getLog()
            }
        }
    }

    @ViewBuilder
    func detailsBuilder(for entry: OSLogEntryLog) -> Text {
        // No accebility labels are used,
        // If added it will _always_ file to check in compile time.
        getLogLevelIcon(level: entry.level) +
        Text(" ") +
        Text(entry.date, style: .time) +
        Text(" ") +
        Text("\(Image(systemName: "building.columns")) \(entry.sender) ") +
        Text("\(Image(systemName: "gearshape.2")) \(entry.subsystem) ") +
        Text("\(Image(systemName: "square.stack.3d.up")) \(entry.category)")
    }

    func getLogLevelIcon(level: OSLogEntryLog.Level) -> Text {
        switch level {
        case .undefined, .notice:
            Text(Image(systemName: "bell.square.fill"))
                .accessibilityLabel("Notice")
        case .debug:
            Text(Image(systemName: "stethoscope"))
                .accessibilityLabel("Debug")
        case .info:
            Text(Image(systemName: "info.square"))
                .accessibilityLabel("Information")
        case .error:
            Text(Image(systemName: "exclamationmark.2"))
                .accessibilityLabel("Error")
        case .fault:
            Text(Image(systemName: "exclamationmark.3"))
                .accessibilityLabel("Fault")
        default:
            Text(Image(systemName: "bell.square.fill"))
                .accessibilityLabel("Default")
        }
    }

    func getBackgroundColor(level: OSLogEntryLog.Level) -> Color {
        switch level {
        case .undefined, .debug, .info, .notice:
            Color.white
        case .error:
            Color.yellow
        case .fault:
            Color.red
        default:
            Color.clear
        }
    }

    public func getLog() async {
        finishedCollecting = false

        do {
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let sinceDate = logStore.position(date: since)
            let predicate = NSPredicate(format: "subsystem BEGINSWITH %@", subsystem)
            let allEntries = try logStore.getEntries(at: sinceDate, matching: predicate)

            logMessages = allEntries.compactMap { $0 as? OSLogEntryLog }
        } catch {
            os_log(.fault, "Something went wrong %@", error as NSError)
        }

        finishedCollecting = true
    }
}

#Preview {
    OSLogViewer()
}
