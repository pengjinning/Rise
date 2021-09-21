//
//  Log.swift
//  Rise
//
//  Created by Vladimir Korolev on 10.11.2019.
//  Copyright © 2019-2020 VladimirBrejcha. All rights reserved.
//

import Foundation

func log(
    _ type: LogType,
    _ message: String? = nil,
    _ file: String = #file,
    _ line: Int = #line,
    _ function: String = #function
) {
    if let message = message {
        print("\(file.onlyFileName):\(line) - \(function) \n\(message) \n")
    } else {
        print("\(file.onlyFileName):\(line) - \(function)")
    }
}

fileprivate extension String {
    var onlyFileName: String {
        URL(fileURLWithPath: self, isDirectory: false).lastPathComponent
    }
}

enum LogType {
    case error
    case warning
    case info
    
    var prefix: String {
        switch self {
        case .error: return "RISE ERROR"
        case .warning: return "RISE WARNING"
        case .info: return "RISE INFO"
        }
    }
}
