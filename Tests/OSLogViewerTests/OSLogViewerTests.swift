import XCTest
@testable import OSLogViewer

final class OSLogViewerTests: XCTestCase {
    func testArchiveContainsRecordDetails() throws {
#if canImport(OSLog)
        let date = try XCTUnwrap(
            Calendar(identifier: .gregorian).date(
                from: DateComponents(
                    timeZone: TimeZone(secondsFromGMT: 0),
                    year: 2026,
                    month: 6,
                    day: 14,
                    hour: 12
                )
            )
        )
        let record = OSLogRecord(
            id: .init(date: date, sequence: 0),
            date: date,
            level: .error,
            composedMessage: "An error occurred",
            sender: "ExampleApp",
            subsystem: "com.example.app",
            category: "network"
        )

        let archive = OSLogArchive.make(
            records: [record],
            appName: "Example App",
            generatedAt: date
        )

        XCTAssertTrue(archive.contains("This is the OSLog archive for Example App."))
        XCTAssertTrue(archive.contains("An error occurred"))
        XCTAssertTrue(archive.contains("❗"))
        XCTAssertTrue(archive.contains("ExampleApp"))
        XCTAssertTrue(archive.contains("com.example.app"))
        XCTAssertTrue(archive.contains("network"))
#endif
    }

    func testRecordIdentityDistinguishesEntriesWithTheSameDate() {
#if canImport(OSLog)
        let date = Date(timeIntervalSince1970: 0)

        XCTAssertNotEqual(
            OSLogRecord.RecordID(date: date, sequence: 0),
            OSLogRecord.RecordID(date: date, sequence: 1)
        )
#endif
    }
}
