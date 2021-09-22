//
//  CallCodingPath.swift
//  FearlessDemo
//
//  Created by li shuai on 2021/8/5.
//

import Foundation
public struct CallCodingPath: Equatable, Codable {
    let moduleName: String
    let callName: String
}

public extension CallCodingPath {
    var isTransfer: Bool {
        [.transfer, .transferKeepAlive].contains(self)
    }

    static var transfer: CallCodingPath {
        CallCodingPath(moduleName: "Balances", callName: "transfer")
    }

    static var transferKeepAlive: CallCodingPath {
        CallCodingPath(moduleName: "Balances", callName: "transfer_keep_alive")
    }
}