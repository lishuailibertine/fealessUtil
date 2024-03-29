//
//  RPCmethod.swift
//  TestFearlessSDK
//
//  Created by li shuai on 2021/9/22.
//

import Foundation

public enum RPCMethod {
    public  static let storageSubscibe = "state_subscribeStorage"
    public static let chain = "system_chain"
    public static let getStorage = "state_getStorage"
    public static let getStorageKeysPaged = "state_getKeysPaged"
    public static let queryStorageAt = "state_queryStorageAt"
    public static let getChildStorageAt = "childstate_getStorage"
    public static let getBlockHash = "chain_getBlockHash"
    public static let submitExtrinsic = "author_submitExtrinsic"
    public static let paymentInfo = "payment_queryInfo"
    public static let getRuntimeVersion = "chain_getRuntimeVersion"
    public static let getStateRuntimeVersion = "state_getRuntimeVersion"
    public static let getRuntimeMetadata = "state_getMetadata"
    public static let getChainBlock = "chain_getBlock"
    public static let getExtrinsicNonce = "system_accountNextIndex"
    public  static let helthCheck = "system_health"
    public static let getSystemProperties = "system_properties"
    public static let runtimeVersionSubscribe = "state_subscribeRuntimeVersion"
}
