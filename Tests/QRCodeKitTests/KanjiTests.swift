//
//  KanjiTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 23.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct KanjiTests {
    @Test(arguments: [
        Character("\u{3000}"): UInt16(0x0000), // Shift JIS: 0x8140
        Character("あ"): UInt16(0x0120), // Shift JIS: 0x82A0
        Character("ア"): UInt16(0x0181), // Shift JIS: 0x8341
        Character("漢"): UInt16(0x073F), // Shift JIS: 0x8ABF
        Character("字"): UInt16(0x0A1A), // Shift JIS: 0x8E9A
        Character("滌"): UInt16(0x173C), // Shift JIS: 0x9FFC
    ])
    func valueForCharactersInFirstRange(
        character: Character,
        expectedValue: UInt16
    ) {
        #expect(Kanji.value(for: character) == expectedValue)
    }
    
    @Test(arguments: [
        Character("漾"): UInt16(0x1740), // Shift JIS: 0xE040
        Character("茗"): UInt16(0x1AAA), // Shift JIS: 0xE4AA
        Character("蹇"): UInt16(0x1C80), // Shift JIS: 0xE740
        Character("錙"): UInt16(0x1D40), // Shift JIS: 0xE840
        Character("顱"): UInt16(0x1E00), // Shift JIS: 0xE940
        Character("熙"): UInt16(0x1F24), // Shift JIS: 0xEAA4
    ])
    func valueForCharactersInSecondRange(
        character: Character,
        expectedValue: UInt16
    ) {
        #expect(Kanji.value(for: character) == expectedValue)
    }
    
    @Test(arguments: [
        Character("0"), // Shift JIS: 0x30
        Character("A"), // Shift JIS: 0x41
        Character("a"), // Shift JIS: 0x61
        Character("ｱ"), // Shift JIS: 0xB1
        Character("ｶ"), // Shift JIS: 0xB6
        Character("ﾀ"), // Shift JIS: 0xC0
        Character("ﾝ"), // Shift JIS: 0xDD
    ])
    func valueForSingleByteShiftJISCharacters(
        character: Character
    ) {
        #expect(Kanji.value(for: character) == nil)
    }
    
    @Test(arguments: [
        Character("ї"),
        Character("é"),
        Character("€"),
        Character("😀"),
        Character("𠮷"),
    ])
    func valueForUnsupportedCharacters(
        character: Character
    ) {
        #expect(Kanji.value(for: character) == nil)
    }
}
