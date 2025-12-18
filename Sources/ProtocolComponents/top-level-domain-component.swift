public enum TopLevelDomainComponent: String, ProtocolComponent {
    case com
    case net
    case org
    case edu
    case gov
    case info
    case academy
    case io

    case nl
    case de
    case be
    case uk
    case il

    case co_uk
    case co_il

    public var component: String {
        return "." + self.rawValue.replacingUnderscores()
    }
}
