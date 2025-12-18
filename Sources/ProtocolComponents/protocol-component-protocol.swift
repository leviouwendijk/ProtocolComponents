public protocol ProtocolComponent: Sendable, Codable, RawRepresentable where RawValue == String {
    var component: String { get }
}
