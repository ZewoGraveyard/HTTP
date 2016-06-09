import PackageDescription

let package = Package(
    name: "HTTP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/MediaType.git", majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/open-swift/S4.git", majorVersion: 0, minor: 8),
    ]
)
