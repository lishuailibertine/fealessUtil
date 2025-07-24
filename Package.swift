// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FearlessUtils",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FearlessUtils",
            targets: ["FearlessUtils"]),
    ],
    dependencies: [ 
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(name: "TweetNacl", url: "https://github.com/lishuailibertine/tweetnacl-swiftwrap", from: "1.0.5"),
        .package(name: "SubstrateKeychain", url: "https://github.com/lishuailibertine/SubstrateKaychain", from: "0.1.5"),
        .package(name: "SS58Factory", url: "https://github.com/lishuailibertine/SS58Factory", from: "1.0.0"),
        .package(name: "RobinHood", url: "https://github.com/lishuailibertine/robinhood-ios", from: "3.0.0"),
        .package(name: "SwiftyBeaver", url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.5"),
        .package(name: "Starscream", url: "https://github.com/daltoniam/Starscream", from: "4.0.8"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FearlessUtils",
            dependencies: ["BigInt","TweetNacl", "SubstrateKeychain","SS58Factory","RobinHood","SwiftyBeaver","Starscream", "AnyCodable","CryptoSwift"]),
        .testTarget(
            name: "FearlessUtilTests",
            dependencies: ["FearlessUtils"])
    ]
)
