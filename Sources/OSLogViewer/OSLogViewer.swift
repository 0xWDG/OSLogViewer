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
    /// This variable saves the log messages
    private var logMessages: [OSLogEntryLog] = []

    @State
    /// This variable saves the current state
    private var finishedCollecting: Bool = false

    @State
    /// This variable saves the export sheet state
    private var exportSheet: Bool = false

    public var body: some View {
        NavigationView {
            List {
                ForEach(logMessages, id: \.self) { entry in
                    VStack {
                        // Actual log message
                        Text(entry.composedMessage)

                        // Details (time, framework, subsystem, category
                        detailsBuilder(for: entry)
                            .font(.footnote)
                    }
                    .listRowBackground(getBackgroundColor(level: entry.level))
                }
            }
            .navigationViewStyle(.stack) // iPad
            .navigationBarTitle("OSLog viewer", displayMode: .inline)
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        items: export()
                    ).disabled(!finishedCollecting)
                }
            }
        }
        .sheet(isPresented: $exportSheet) {
            ShareLink(
                items: export(),
                subject: Text("OSLog Archive"),
                message: Text("This is the OSLog archive for this application")
            )
        }
        .overlay {
            if logMessages.isEmpty {
                if !finishedCollecting {
                    if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
                        ContentUnavailableView("Collecting logs...", systemImage: "hourglass")
                    } else {
                        VStack {
                            Image(systemName: "hourglass")
                            Text("Collecting logs...")
                        }
                    }
                } else {
                    if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
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

    func export() -> [String] {
        let appName: String = {
            if let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                return displayName
            } else if let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                return name
            }
            return "this application"
        }()

        return [
            [
                "This is the OSLog archive for \(appName).\r\n",
                "Generated on \(Date().formatted())\r\n",
                "Generator https://github.com/0xWDG/OSLogViewer\r\n\r\n",
                logMessages.map {
                    "\($0.composedMessage)\r\n" +
                    getLogLevelEmoji(level: $0.level) +
                    " \($0.date.formatted()) 🏛️ \($0.sender) ⚙️ \($0.subsystem) 🌐 \($0.category)"
                }.joined(separator: "\r\n\r\n"),
            ].joined()
        ]
    }

    @ViewBuilder
    /// Build details (time, framework, subsystem, category), for the footnote row
    /// - Parameter entry: log entry
    /// - Returns: Text containing icons and details.
    func detailsBuilder(for entry: OSLogEntryLog) -> Text {
        // No accebility labels are used,
        // If added it will _always_ file to check in compile time.
        getLogLevelIcon(level: entry.level) +
        Text(" ") +
        Text(entry.date, style: .time) +
        Text(" ") +
        // 􀤨 Framework (aka sender)
        Text("\(Image(systemName: "building.columns")) \(entry.sender) ") +
        // 􀥎 Subsystem
        Text("\(Image(systemName: "gearshape.2")) \(entry.subsystem) ") +
        // 􀦲 Category
        Text("\(Image(systemName: "square.grid.3x3")) \(entry.category)")
    }

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

    /// Generate an icon for the current log level
    /// - Parameter level: log level
    /// - Returns: SF Icon as Text
    func getLogLevelIcon(level: OSLogEntryLog.Level) -> Text {
        switch level {
        case .undefined, .notice:
            // 􀼸
            Text(Image(systemName: "bell.square.fill"))
                .accessibilityLabel("Notice")
        case .debug:
            // 􀝾
            Text(Image(systemName: "stethoscope"))
                .accessibilityLabel("Debug")
        case .info:
            // 􁊇
            Text(Image(systemName: "info.square"))
                .accessibilityLabel("Information")
        case .error:
            // 􀢒
            Text(Image(systemName: "exclamationmark.2"))
                .accessibilityLabel("Error")
        case .fault:
            // 􀣴
            Text(Image(systemName: "exclamationmark.3"))
                .accessibilityLabel("Fault")
        default:
            // 􀼸
            Text(Image(systemName: "bell.square.fill"))
                .accessibilityLabel("Default")
        }
    }
    
    /// Generate the background color for the log message
    /// - Parameter level: log level
    /// - Returns: The appropiate color
    func getBackgroundColor(level: OSLogEntryLog.Level) -> Color {
        switch level {
        case .undefined, .debug, .info, .notice:
            Color(uiColor: UIColor.secondarySystemGroupedBackground)

        case .error:
            // Fetched colors with color picker from Xcode
            // Using a `dynamicProvider` to support light & dark mode.
            Color(uiColor: .init(dynamicProvider: { traits in
                if traits.userInterfaceStyle == .light {
                    return .init(red: 1, green: 0.968, blue: 0.898, alpha: 1)
                } else {
                    return .init(red: 0.858, green: 0.717, blue: 0.603, alpha: 0.4)
                }
            }))

        case .fault:
            // Fetched colors with color picker from Xcode
            // Using a `dynamicProvider` to support light & dark mode.
            Color(uiColor: .init(dynamicProvider: { traits in
                if traits.userInterfaceStyle == .light {
                    return .init(red: 0.98, green: 0.90, blue: 0.90, alpha: 1)
                } else {
                    return .init(red: 0.26, green: 0.15, blue: 0.17, alpha: 1)

                }
            }))

        default:
            Color(uiColor: UIColor.secondarySystemGroupedBackground)
        }
    }
    
    /// Get the logs
    public func getLog() async {
        // We start collecting
        finishedCollecting = false

        do {
            /// Initialize logstore for the current proces
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)

            /// Fetch all logs since a specific date
            let sinceDate = logStore.position(date: since)

            /// Predicate (filter) all results to have the subsystem starting with the given subsystem
            let predicate = NSPredicate(format: "subsystem BEGINSWITH %@", subsystem)

            /// Get all logs from the log store
            let allEntries = try logStore.getEntries(at: sinceDate, matching: predicate)

            /// Remap from `AnySequence<OSLogEntry>` to type `[OSLogEntryLog]`
            logMessages = allEntries.compactMap { $0 as? OSLogEntryLog }
        } catch {
            // We fail to get the results, add this to the log.
            os_log(.fault, "Something went wrong %@", error as NSError)
        }

        // We've finished collecting
        finishedCollecting = true
    }
}

struct OSLogViewer_Previews : PreviewProvider {
    static var previews: some View {
        OSLogViewer()
    }
}
