import PackageDescription

let package = Package(
	name: "HTTP",
	dependencies: [
        .Package(url: "https://github.com/Zewo/Stream.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0, minor: 1),
	]
)
