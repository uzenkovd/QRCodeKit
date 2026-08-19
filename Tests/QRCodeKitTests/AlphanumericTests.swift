//
//  AlphanumericTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 19.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct AlphanumericTests {
    @Test
    func containsAllValidCharacters() {
        let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
        
        for character in characters {
            #expect(Alphanumeric.contains(character))
            
            if character.isLetter {
                #expect(
                    !Alphanumeric.contains(
                        Character(character.lowercased())
                    )
                )
            }
        }
    }

    @Test
    func valuesMatchSpecification() {
        let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
        
        for (index, character) in characters.enumerated() {
            #expect(Alphanumeric.value(for: character) == UInt32(index))
        }
    }

    @Test
    func rejectsInvalidCharacters() {
        let characters: [Character] = [
            "a", "z", "@", "#", "&", "_", "\\", ";", "^", "±", "½", "Ⅳ", "№", "~", "!", "="
        ]
        
        for character in characters {
            #expect(!Alphanumeric.contains(character))
            #expect(Alphanumeric.value(for: character) == nil)
        }
    }
}
