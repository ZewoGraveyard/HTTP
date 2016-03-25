import PackageDescription

let package = Package(
    name: "HTTP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/MediaType.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/swiftx/s4.git", majorVersion: 0, minor: 1)
    ]
)
