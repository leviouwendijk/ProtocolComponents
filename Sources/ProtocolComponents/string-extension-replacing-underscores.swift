import Foundation

extension String {
    public func replacingUnderscores(with string: String = ".") -> String {
        return self.replacingOccurrences(
            of: "_",
            with: string
        )
    }
}
