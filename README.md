# OSLogViewer

OSLogViewer is made for viewing your apps OS_Log history, it is a SwiftUI view which can be used in your app to view and export your logs.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FOSLogViewer%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/0xWDG/OSLogViewer)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F0xWDG%2FOSLogViewer%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/0xWDG/OSLogViewer)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![License](https://img.shields.io/github/license/0xWDG/OSLogViewer)

_Key features:_

- View your apps OS_Log history
- Export logs

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

NavigationLink {
    // Default configuration
    // uses your app's bundle identifier as subsystem
    // and shows all logs from the last hour.
    OSLogViewer()
} label: {
    Text("View logs")
}
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

<img src='https://github.com/0xWDG/OSLogViewer/assets/1290461/c2f870b5-cb7c-42f0-bdfd-78b88b73bb3a' height='500'>

## Export example

```plaintext
This is the OSLog archive for exampleapp
Generated on 2/6/2024, 11:53
Generator https://github.com/0xWDG/OSLogViewer

Info message
ℹ️ 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory

Error message
❗ 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory

Error message
❗ 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory

Critical message
‼️ 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory

Log message
🔔 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory

Log message
🔔 2/6/2024, 11:53 🏛️ exampleapp ⚙️ nl.wesleydegroot.exampleapp 🌐 myCategory
```

## Changelog

- 1.0.0
  - Initial release
- 1.0.1
  - Improved support for dark mode.
  - Colors are more similar to Xcode's console.
  - Added support for exporting logs.

## Contact

We can get in touch via [Twitter/X](https://twitter.com/0xWDG), [Discord](https://discordapp.com/users/918438083861573692), [Mastodon](https://mastodon.social/@0xWDG), [Email](mailto:email+oss@wesleydegroot.nl), [Website](https://wesleydegroot.nl).
