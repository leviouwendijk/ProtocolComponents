import Foundation

public enum WebOriginError: Error, LocalizedError, Sendable, Equatable {
    case blank
    case invalid(String)
    case unsupportedScheme(String)
    case missingHost(String)
    case containsPath(String)
    case containsQuery(String)
    case containsFragment(String)

    public var errorDescription: String? {
        switch self {
        case .blank:
            return "Web origin cannot be blank."

        case .invalid(let value):
            return "Invalid web origin: \(value)"

        case .unsupportedScheme(let value):
            return "Web origin must use http or https: \(value)"

        case .missingHost(let value):
            return "Web origin must include a host: \(value)"

        case .containsPath(let value):
            return "Web origin must not include a path: \(value)"

        case .containsQuery(let value):
            return "Web origin must not include a query: \(value)"

        case .containsFragment(let value):
            return "Web origin must not include a fragment: \(value)"
        }
    }
}

public struct WebOrigin: Sendable, Codable, Equatable, Hashable, CustomStringConvertible {
    public let value: String

    public init(
        parsing rawValue: String
    ) throws {
        let rawValue = rawValue.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !rawValue.isEmpty else {
            throw WebOriginError.blank
        }

        guard let components = URLComponents(string: rawValue) else {
            throw WebOriginError.invalid(rawValue)
        }

        guard let scheme = components.scheme?.lowercased() else {
            throw WebOriginError.invalid(rawValue)
        }

        guard scheme == "http" || scheme == "https" else {
            throw WebOriginError.unsupportedScheme(rawValue)
        }

        guard let host = components.host?.lowercased(), !host.isEmpty else {
            throw WebOriginError.missingHost(rawValue)
        }

        if components.query != nil {
            throw WebOriginError.containsQuery(rawValue)
        }

        if components.fragment != nil {
            throw WebOriginError.containsFragment(rawValue)
        }

        if !components.path.isEmpty && components.path != "/" {
            throw WebOriginError.containsPath(rawValue)
        }

        var canonical = "\(scheme)://\(host)"

        if let port = components.port {
            canonical += ":\(port)"
        }

        self.value = canonical
    }

    public init(
        scheme: HTTPProtocolComponent = .https,
        host: String,
        port: Int? = nil
    ) throws {
        let host = host.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !host.isEmpty else {
            throw WebOriginError.blank
        }

        var value = scheme.component + host.lowercased()

        if let port {
            value += ":\(port)"
        }

        try self.init(parsing: value)
    }

    public init(
        scheme: HTTPProtocolComponent = .https,
        subdomains: [String] = [],
        host: String,
        tld: TopLevelDomainComponent,
        port: Int? = nil
    ) throws {
        let labels = (
            subdomains +
            [host]
        )
        .map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }

        guard !labels.isEmpty else {
            throw WebOriginError.blank
        }

        var value =
            scheme.component +
            labels.joined(separator: ".").lowercased() +
            tld.component

        if let port {
            value += ":\(port)"
        }

        try self.init(parsing: value)
    }

    public static func http(
        _ host: String,
        port: Int? = nil
    ) throws -> Self {
        try .init(
            scheme: .http,
            host: host,
            port: port
        )
    }

    public static func https(
        _ host: String,
        port: Int? = nil
    ) throws -> Self {
        try .init(
            scheme: .https,
            host: host,
            port: port
        )
    }

    public var description: String {
        return value
    }
}
