import Foundation
import SwiftyBeaver

public protocol LoggerProtocol {
     func verbose(message: String, file: String, function: String, line: Int)
     func debug(message: String, file: String, function: String, line: Int)
     func info(message: String, file: String, function: String, line: Int)
     func warning(message: String, file: String, function: String, line: Int)
     func error(message: String, file: String, function: String, line: Int)
}

public extension LoggerProtocol {
    func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        verbose(message: message, file: file, function: function, line: line)
    }

      func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        debug(message: message, file: file, function: function, line: line)
    }

      func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        info(message: message, file: file, function: function, line: line)
    }

     func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        warning(message: message, file: file, function: function, line: line)
    }

     func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        error(message: message, file: file, function: function, line: line)
    }
}

public final class Logger {
    public  static let shared = Logger()

    public  let log = SwiftyBeaver.self

    public  var minLevel: SwiftyBeaver.Level? {
        get {
            log.destinations.first?.minLevel
        }

        set {
            log.removeAllDestinations()

            if let level = newValue {
                let destination = ConsoleDestination()
                destination.minLevel = level
                log.addDestination(destination)
            }
        }
    }

    private init() {
        let destination = ConsoleDestination()

        #if F_DEV
            destination.minLevel = .verbose
        #else
            destination.minLevel = .info
        #endif

        log.addDestination(destination)
    }
}

 extension Logger: LoggerProtocol {
    public  func verbose(message: String, file: String, function: String, line: Int) {
        log.custom(
            level: .verbose,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public func debug(message: String, file: String, function: String, line: Int) {
        log.custom(
            level: .debug,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public  func info(message: String, file: String, function: String, line: Int) {
        log.custom(
            level: .info,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(message: String, file: String, function: String, line: Int) {
        log.custom(
            level: .warning,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    public  func error(message: String, file: String, function: String, line: Int) {
        log.custom(
            level: .error,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }
}
