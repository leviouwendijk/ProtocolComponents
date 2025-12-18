public enum HTTPProtocolComponent: String, ProtocolComponent {
    case http
    case https

    public var component: String {
        return self.rawValue + "://"
    }
}
