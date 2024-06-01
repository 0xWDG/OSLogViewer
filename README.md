# OSLogViewer

This SwiftUI view/framework is meant for viewing your apps OS_Log history.

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 13+, macOS 10.15+

## Installation

Install using Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/0xWDG/OSLogViewer.git", .branch("main")),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "OSLogViewer", package: "OSLogViewer"),
    ]),
]
```

And import it:

```swift
import OSLogViewer
```

## Usage

### Quick usage

```swift
import OSLogViewer

// Default configuration
// uses your app's bundle identifier as subsystem
// and shows all logs from the last hour.

OSLogViewer()
```

### Custom usage

custom subsystem

```swift
import OSLogViewer

OSLogViewer(
    subsystem: "nl.wesleydegroot.exampleapp",
)
```

custom time

```swift
import OSLogViewer

OSLogViewer(
    since: Date().addingTimeInterval(-7200) // 2 hours
)
```

custom subsystem and time

```swift
import OSLogViewer

OSLogViewer(
    subsystem: "nl.wesleydegroot.exampleapp",
    since: Date().addingTimeInterval(-7200) // 2 hours
)
```

## Screenshots

<img src='https://github.com/0xWDG/OSLogViewer/assets/1290461/19acba9f-d369-4c1e-bda5-643c7b87a017' height='500'>

## Contact

We can get in touch via [Twitter/X](https://twitter.com/0xWDG), [Discord](https://discordapp.com/users/918438083861573692), [Mastodon](https://iosdev.space/@0xWDG), [Threads](https://threads.net/@0xwdg), [Bluesky](https://bsky.app/profile/0xwdg.bsky.social).

Alternatively you can visit my [Website](https://wesleydegroot.nl).
