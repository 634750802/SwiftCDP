import Foundation

public protocol Model {
  static var name: String { get }
}

extension Model {
  public static var name: String {
    "\(String(describing: Self.self))"
  }
}

public protocol ModelMethod: Encodable {
  associatedtype Result: Decodable
  associatedtype TransformedResult = Result
  associatedtype Model: ChromeDevtoolProtocol.Model
  static var name: String { get }
  static func transform(client: ChromeClient, result: Result) -> TransformedResult
}

public protocol ModelEvent: Decodable {
  associatedtype Model: ChromeDevtoolProtocol.Model
}


public extension ModelMethod where TransformedResult == Result {
  static func transform(result: Result) -> TransformedResult {
    result
  }
}

public extension ModelMethod {
  static var method: String {
    "\(Self.Model.name).\(String(describing: Self.self))"
  }
}

public extension ModelEvent {
  static var name: String {
    "\(Self.Model.name)).\(String(describing: Self.self))"
  }
}

public protocol ExperimentalFeature {}


public enum JsonNumber: Codable {
  case int(Int)
  case double(Double)

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
      case .int(let value):
        try container.encode(value)
      case .double(let value):
        try container.encode(value)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let raw = try container.decode(String.self)
    if raw.contains(".") {
      self = .double(Double(raw)!)
    } else {
      self = .int(Int(raw)!)
    }
  }
}

extension JsonNumber: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

extension JsonNumber: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .double(value)
  }
}


public enum JsonPrimitive: Codable {
  case int(Int)
  case double(Double)
  case string(String)
  case boolean(Bool)
  case null

  public init(from decoder: Decoder) throws {
    let c = try decoder.singleValueContainer()
    if c.decodeNil() {
      self = .null
    } else if let value = try? c.decode(Int.self) {
      self = .int(value)
    } else if let value = try? c.decode(Double.self) {
      self = .double(value)
    } else if let value = try? c.decode(String.self) {
      self = .string(value)
    } else if let value = try? c.decode(Bool.self) {
      self = .boolean(value)
    } else {
      self = .string("<JSON: Unsupported value>")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
      case .int(let value):
        try container.encode(value)
      case .boolean(let value):
        try container.encode(value)
      case .string(let value):
        try container.encode(value)
      case .double(let value):
        try container.encode(value)
      case .null:
        try container.encodeNil()
    }
  }
}

extension JsonPrimitive: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = .int(value)
  }
}

extension JsonPrimitive: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = .double(value)
  }
}

extension JsonPrimitive: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = .boolean(value)
  }
}

extension JsonPrimitive: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = .string(value)
  }
}

extension JsonPrimitive: ExpressibleByNilLiteral {
  public init(nilLiteral: Void) {
    self = .null
  }
}
