//
//  QRStructureRendererPlainStyleTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 08.11.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct QRStructureRendererPlainStyleTests {
    @Test(arguments: [
        (.data(color: .dark), "1"),
        (.data(color: .light), "0"),
        (.function(pattern: .finder, color: .dark), "F"),
        (.function(pattern: .finder, color: .light), "f"),
        (.function(pattern: .separator, color: .dark), "S"),
        (.function(pattern: .separator, color: .light), "s"),
        (.function(pattern: .alignment, color: .dark), "A"),
        (.function(pattern: .alignment, color: .light), "a"),
        (.function(pattern: .timing, color: .dark), "T"),
        (.function(pattern: .timing, color: .light), "t"),
        (.information(type: .format, color: .dark), "I"),
        (.information(type: .format, color: .light), "i"),
        (.information(type: .version, color: .dark), "V"),
        (.information(type: .version, color: .light), "v"),
        (.darkModule, "D"),
        (.reserved(.format), "R"),
        (.reserved(.version), "R"),
        (.unset, "?")
    ] as [(QRModule, Character)])
    func rendersModuleCharacter(
        module: QRModule,
        character: Character
    ) {
        #expect(QRStructureRenderer.character(for: module) == character)
    }

    @Test
    func separatesModulesWithSpaces() {
        let row = QRStructureRenderer.plainRow([
            .data(color: .dark),
            .function(pattern: .finder, color: .light),
            .unset
        ])

        #expect(row == "1 f ?")
    }
}
