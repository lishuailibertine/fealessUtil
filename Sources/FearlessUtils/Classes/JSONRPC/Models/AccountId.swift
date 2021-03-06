//
//  AccountId.swift
//  FearlessDemo
//
//  Created by li shuai on 2021/8/5.
//

import Foundation


public struct AccountId: ScaleCodable {
    public let value: Data

    public init(scaleDecoder: ScaleDecoding) throws {
        value = try scaleDecoder.readAndConfirm(count: 32)
    }

    public func encode(scaleEncoder: ScaleEncoding) throws {
        scaleEncoder.appendRaw(data: value)
    }
}
