import Foundation
import SubstrateKeychain
import BigInt

public protocol SubstarteExtrinsicFactoryProtocol {
     static func transferExtrinsic(from senderAccountId: AccountType,
                                  transferCall: ScaleCodable?,
                                  tip: BigUInt?,
                                  additionalParameters: SubstrateExtrinsicParameters,
                                  signer: @escaping (Data) throws -> Data) throws -> Data
}

public struct SubstrateExtrinsicParameters {
    public let nonce: UInt32
    public let genesisHash: Data
    public let blockHash: Data
    public let specVersion: UInt32
    public let transactionVersion: UInt32
    public let signatureVersion: UInt8
    public let moduleIndex: UInt8
    public let callIndex: UInt8
    public let tip: BigUInt?
    public let paymentData: Data?
    public let mode: Bool
    public let metadataHash: Data
    public let runtimeMetadata: RuntimeMetadataProtocol
    public init(nonce: UInt32,genesisHash: Data,blockHash: Data,specVersion: UInt32,transactionVersion: UInt32,signatureVersion: UInt8,moduleIndex: UInt8,callIndex: UInt8,tip: BigUInt?,paymentData: Data? = nil, mode: Bool, metadataHash: Data, runtimeMetadata: RuntimeMetadataProtocol){
        self.nonce = nonce
        self.genesisHash = genesisHash
        self.blockHash = blockHash
        self.specVersion = specVersion
        self.transactionVersion = transactionVersion
        self.signatureVersion = signatureVersion
        self.moduleIndex = moduleIndex
        self.callIndex = callIndex
        self.tip = tip
        self.paymentData = paymentData
        self.mode = mode
        self.metadataHash = metadataHash
        self.runtimeMetadata = runtimeMetadata
    }
}

public struct SubstrateExtrinsicFactory: SubstarteExtrinsicFactoryProtocol {
    public  static let extrinsicVersion: UInt8 = 132
    static let payloadHashingTreshold = 256
    public static func transferExtrinsic(from senderAccountId: AccountType,
                                  transferCall: ScaleCodable?,
                                  tip: BigUInt? = 0,
                                  additionalParameters: SubstrateExtrinsicParameters,
                                  signer: @escaping (Data) throws -> Data) throws -> Data {
        let callEncoder = ScaleEncoder()
        try transferCall?.encode(scaleEncoder: callEncoder)
        let callArguments = callEncoder.encode()

        let call = Call(moduleIndex: additionalParameters.moduleIndex,
                        callIndex: additionalParameters.callIndex,
                        arguments: callArguments)

        let era = Era.immortal
        let payload = ExtrinsicPayload(call: call,
                                       era: era,
                                       nonce: additionalParameters.nonce,
                                       tip: tip!,
                                       paymentData: additionalParameters.paymentData,
                                       mode: additionalParameters.mode,
                                       specVersion: additionalParameters.specVersion,
                                       transactionVersion: additionalParameters.transactionVersion,
                                       genesisHash: additionalParameters.genesisHash,
                                       blockHash: additionalParameters.blockHash,
                                       metadataHash: additionalParameters.metadataHash,
                                       metadata: additionalParameters.runtimeMetadata)

        let payloadEncoder = ScaleEncoder()
        try payload.encode(scaleEncoder: payloadEncoder)

        var payloadData = payloadEncoder.encode()

        payloadData = payloadData.count > Self.payloadHashingTreshold ? (try payloadData.blake2b32()) : payloadData
        
        let signature = try signer(payloadData)

        let transaction = ExtrinsicTransaction(accountType: senderAccountId,
                                               signatureVersion: additionalParameters.signatureVersion,
                                               signature: signature,
                                               era: era,
                                               nonce: additionalParameters.nonce,
                                               tip: tip!,
                                               paymentData: additionalParameters.paymentData,
                                               mode: additionalParameters.mode,
                                               metadata: additionalParameters.runtimeMetadata)

        let extrinsic = ExtrinsicAsset(version: Self.extrinsicVersion,
                                  transaction: transaction,
                                  call: call)

        let extrinsicCoder = ScaleEncoder()
        try extrinsic.encode(scaleEncoder: extrinsicCoder)

        return extrinsicCoder.encode()
    }
}
