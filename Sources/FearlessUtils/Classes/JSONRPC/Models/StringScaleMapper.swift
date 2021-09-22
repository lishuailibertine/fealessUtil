import Foundation

public struct StringScaleMapper<T: LosslessStringConvertible & Equatable>: Codable, Equatable {
    public  let value: T

    public  init(value: T) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let strValue = try container.decode(String.self)

        guard let convertedValue = T(strValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Can't decode value: \(strValue)"
            )
        }

        value = convertedValue
    }

    public  func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(value))
    }
}
