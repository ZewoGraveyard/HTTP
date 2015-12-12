import PackageDescription

let package = Package(
	name: "HTTP",
	dependencies: [
        .Package(url: "https://github.com/Zewo/Core.git", majorVersion: 0, minor: 1)
	]
)
