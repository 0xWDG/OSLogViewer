//
//  OSLogViewer.swift
//  OSLogViewer
//
//  Created by Wesley de Groot on 01/06/2024.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/OSLogViewer
//  MIT LICENCE

#if canImport(SwiftUI) && canImport(OSLog)
import SwiftUI
@preconcurrency import OSLog

/// Displays and exports the current process's OSLog history.
public struct OSLogViewer: View {
    /// Subsystem to read logs from
    public let subsystem: String

    /// Date from which logs should be read.
    public let since: Date

    /// Creates an OSLog viewer.
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

    @State
    /// Immutable log records displayed by the list.
    private var logMessages: [OSLogRecord] = []

    @State
    /// Current loading state.
    private var loadingState: LoadingState = .loading

    @State
    /// Archive prepared when logs finish loading.
    private var exportedArchive: String = ""

    @State
    /// Identifier used to prevent an older request from publishing stale results.
    private var loadIdentifier = UUID()

    /// The body of the view
    public var body: some View {
        List(logMessages) { entry in
            VStack {
                Text(entry.composedMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                details(for: entry)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
            }
            .accessibilityElement(children: .combine)
            .listRowBackground(backgroundColor(for: entry.level))
        }
        .modifier(NavigationTitleModifier())
        .toolbar {
#if os(macOS)
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                ShareLink(
                    item: exportedArchive
                )
                .disabled(!loadingState.isLoaded)
            }
#elseif !os(tvOS) && !os(watchOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                    ShareLink(
                        item: exportedArchive
                    )
                    .disabled(!loadingState.isLoaded)
                }
            }
#else
            EmptyView()
#endif
        }
        .overlay {
            if logMessages.isEmpty {
                switch loadingState {
                case .loading:
                    if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
                        ContentUnavailableView("Collecting logs...", systemImage: "hourglass")
                    } else {
                        VStack {
                            Image(systemName: "hourglass")
                            Text("Collecting logs...")
                        }
                    }
                case .loaded:
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
                case .failed(let message):
                    if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) {
                        ContentUnavailableView(
                            "Unable to collect logs",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                    } else {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Unable to collect logs")
                            Text(message)
                        }
                    }
                }
            }
        }
        .refreshable {
            await getLog()
        }
        .task(id: LoadRequest(subsystem: subsystem, since: since)) {
            await getLog()
        }
    }

    /// Build details (time, framework, subsystem, category), for the footnote row
    /// - Parameter entry: log entry
    /// - Returns: Text containing icons and details.
    func details(for entry: OSLogRecord) -> Text {
        logLevelIcon(for: entry.level) +
        // Non breaking space
        Text("\u{00a0}") +
        // Date
        Text(entry.date, style: .time) +
        // (Breaking) space
        Text(" ") +
        // 􀤨 Framework (aka sender)
        Text("\(Image(systemName: "building.columns"))\u{00a0}\(entry.sender) ") +
        // 􀥎 Subsystem
        Text("\(Image(systemName: "gearshape.2"))\u{00a0}\(entry.subsystem) ") +
        // 􀦲 Category
        Text("\(Image(systemName: "square.grid.3x3"))\u{00a0}\(entry.category)")
    }

    /// Generate an icon for the current log level
    /// - Parameter level: log level
    /// - Returns: SF Icon as Text
    func logLevelIcon(for level: OSLogRecord.Level) -> Text {
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
        }
    }

    /// Reloads the displayed logs.
    @MainActor
    public func getLog() async {
        let identifier = UUID()
        loadIdentifier = identifier
        loadingState = .loading

        do {
            let records = try await OSLogLoader.records(
                subsystem: subsystem,
                since: since
            )

            guard !Task.isCancelled, loadIdentifier == identifier else {
                return
            }

            logMessages = records
            exportedArchive = OSLogArchive.make(records: records)
            loadingState = .loaded
        } catch {
            guard !Task.isCancelled, loadIdentifier == identifier else {
                return
            }

            os_log(.fault, "Something went wrong %@", error as NSError)
            loadingState = .failed(error.localizedDescription)
        }
    }

    struct NavigationTitleModifier: ViewModifier {
        func body(content: Content) -> some View {
#if os(macOS) || os(tvOS) || os(watchOS)
            content
#else
            content
                .navigationTitle("OSLog viewer")
                .navigationBarTitleDisplayMode(.inline)
#endif
        }
    }

    private struct LoadRequest: Hashable {
        let subsystem: String
        let since: Date
    }

    private enum LoadingState {
        case loading
        case loaded
        case failed(String)

        var isLoaded: Bool {
            if case .loaded = self {
                true
            } else {
                false
            }
        }
    }
}

struct OSLogViewer_Previews: PreviewProvider {
    static var previews: some View {
        OSLogViewer()
    }
}
#endif
