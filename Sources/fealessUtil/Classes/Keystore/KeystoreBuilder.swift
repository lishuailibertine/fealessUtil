import Foundation
import scrypt
import TweetNacl

public class KeystoreBuilder {
    private var name: String?
    private var creationDate = Date()
    private var genesisHash: String?

    public init() {}
}

extension KeystoreBuilder: KeystoreBuilding {
    public func with(name: String) -> Self {
        self.name = name
        return self
    }

    public func with(creationDate: Date) -> Self {
        self.creationDate = creationDate
        return self
    }

    public func with(genesisHash: String) -> Self {
        self.genesisHash = genesisHash
        return self
    }

    public func build(from data: KeystoreData, password: String?) throws -> KeystoreDefinition {
        let scryptParameters = try ScryptParameters()

        let scryptData: Data

        if let password = password {
            guard let passwordData = password.data(using: .utf8) else {
                throw KeystoreExtractorError.invalidPasswordFormat
            }

            scryptData = passwordData
        } else {
            scryptData = Data()
        }
        
        let passworld = [UInt8](scryptData)
        let salt = [UInt8](scryptParameters.salt)
        var encryptionKey:[UInt8] = []
        crypto_scrypt(passworld, passworld.count, salt, salt.count, UInt64(UInt(scryptParameters.scryptN)), UInt32(UInt(scryptParameters.scryptP)), UInt32(UInt(scryptParameters.scryptR)), &encryptionKey, Int(UInt(KeystoreConstants.encryptionKeyLength)))
        
        let nonce = try Data.gerateRandomBytes(of: KeystoreConstants.nonceLength)

        let secretKeyData: Data = data.secretKeyData

        let pcksData = KeystoreConstants.pkcs8Header + secretKeyData +
            KeystoreConstants.pkcs8Divider + data.publicKeyData
        let encrypted = try NaclSecretBox.secretBox(message: pcksData, nonce: nonce, key: Data(encryptionKey))
        let encoded = scryptParameters.encode() + nonce + encrypted

        let encodingType = [KeystoreEncodingType.scrypt.rawValue, KeystoreEncodingType.xsalsa.rawValue]
        let encodingContent = [KeystoreEncodingContent.pkcs8.rawValue, data.cryptoType.rawValue]
        let keystoreEncoding = KeystoreEncoding(content: encodingContent,
                                                type: encodingType,
                                                version: String(KeystoreConstants.version))

        let meta = KeystoreMeta(name: name,
                                createdAt: Int64(creationDate.timeIntervalSince1970),
                                genesisHash: genesisHash)

        return KeystoreDefinition(address: data.address,
                                  encoded: encoded.base64EncodedString(),
                                  encoding: keystoreEncoding,
                                  meta: meta)
    }
}
