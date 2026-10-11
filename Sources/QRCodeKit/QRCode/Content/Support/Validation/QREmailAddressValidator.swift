//
//  QREmailAddressValidator.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 10.10.2026.
//

enum QREmailAddressValidator {
    static func isValid(_ address: String) -> Bool {
        let parts = address.split(
            separator: "@",
            omittingEmptySubsequences: false
        )

        guard
            parts.count == 2,
            address.utf8.count <= 254
        else {
            return false
        }

        return isValidLocalPart(parts[0])
            && isValidDomain(parts[1])
    }
}

// MARK: - Private Helpers

private extension QREmailAddressValidator {
    static func isValidLocalPart(_ localPart: Substring) -> Bool {
        guard (1...64).contains(localPart.utf8.count) else {
            return false
        }

        let allowedCharacters = Set(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-/=?^_`{|}~".utf8
        )

        let atoms = localPart.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        return atoms.allSatisfy { atom in
            !atom.isEmpty
                && atom.utf8.allSatisfy { allowedCharacters.contains($0) }
        }
    }

    static func isValidDomain(_ domain: Substring) -> Bool {
        guard (1...253).contains(domain.utf8.count) else {
            return false
        }

        let allowedCharacters = Set(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-".utf8
        )

        let labels = domain.split(
            separator: ".",
            omittingEmptySubsequences: false
        )

        return labels.allSatisfy { label in
            let bytes = label.utf8

            return (1...63).contains(bytes.count)
                && bytes.first != UInt8(ascii: "-")
                && bytes.last != UInt8(ascii: "-")
                && bytes.allSatisfy { allowedCharacters.contains($0) }
        }
    }
}
