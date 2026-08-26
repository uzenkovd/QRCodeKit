//
//  DataAnalyzerTests.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 26.08.2026.
//

import Testing
@testable import QRCodeKit

@Suite
struct DataAnalyzerTests {
    
    // MARK: - canEncode(_:)
    
    @Test
    func canEncodeSupportedMessages() {
        let analyzer = DataAnalyzer()
        
        let messages = [
            "0123456789",
            "HELLO WORLD",
            "日本語",
            "Café"
        ]
        
        for message in messages {
            #expect(analyzer.canEncode(message))
        }
    }
    
    @Test
    func cannotEncodeUnsupportedMessage() {
        let analyzer = DataAnalyzer()
        
        #expect(analyzer.canEncode("🙂𠜎") == false)
    }
    
    @Test
    func cannotEncodeEmptyMessage() {
        let analyzer = DataAnalyzer()
        
        #expect(analyzer.canEncode("") == false)
    }
    
    // MARK: - canFit(characterCount:mode:)
    
    @Test
    func canFitAtMaximumCapacity() {
        let analyzer = DataAnalyzer()
        
        let maxCapacities: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 7089),
            (.alphanumeric, 4296),
            (.kanji, 1817),
            (.byte, 2953)
        ]
        
        for capacity in maxCapacities {
            #expect(
                analyzer.canFit(
                    characterCount: capacity.characterCount,
                    mode: capacity.mode
                )
            )
        }
    }
    
    @Test
    func cannotFitAboveMaximumCapacity() {
        let analyzer = DataAnalyzer()
        
        let exceedingCounts: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 7089 + 1),
            (.alphanumeric, 4296 + 1),
            (.kanji, 1817 + 1),
            (.byte, 2953 + 1)
        ]
        
        for value in exceedingCounts {
            #expect(
                !analyzer.canFit(
                    characterCount: value.characterCount,
                    mode: value.mode
                )
            )
        }
    }
    
    // MARK: - canFit(characterCount:mode:errorCorrectionLevel:version:)
    
    @Test
    func canFitAtConfigurationCapacity() {
        let analyzer = DataAnalyzer()
        
        let capacities: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 17),
            (.alphanumeric, 10),
            (.kanji, 4),
            (.byte, 7)
        ]
        
        for capacity in capacities {
            #expect(
                analyzer.canFit(
                    characterCount: capacity.characterCount,
                    mode: capacity.mode,
                    errorCorrectionLevel: .H,
                    version: .v1
                )
            )
        }
    }
    
    @Test
    func cannotFitAboveConfigurationCapacity() {
        let analyzer = DataAnalyzer()
        
        let exceedingCounts: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 17 + 1),
            (.alphanumeric, 10 + 1),
            (.kanji, 4 + 1),
            (.byte, 7 + 1)
        ]
        
        for value in exceedingCounts {
            #expect(
                !analyzer.canFit(
                    characterCount: value.characterCount,
                    mode: value.mode,
                    errorCorrectionLevel: .H,
                    version: .v1
                )
            )
        }
    }
    
    // MARK: - recommendedEncodingMode(for:)
    
    @Test
    func recommendsMostEfficientEncodingMode() {
        let analyzer = DataAnalyzer()
        
        let cases: [(message: String, expectedMode: EncodingMode)] = [
            ("0123456789", .numeric),
            ("HELLO WORLD", .alphanumeric),
            ("日本語", .kanji),
            ("Café", .byte)
        ]
        
        for testCase in cases {
            #expect(
                analyzer.recommendedEncodingMode(for: testCase.message) == testCase.expectedMode
            )
        }
    }
    
    @Test
    func returnsNoRecommendedEncodingModeForUnsupportedMessage() {
        let analyzer = DataAnalyzer()
        
        let result = analyzer.recommendedEncodingMode(for: "🙂𠜎")
        
        #expect(result == nil)
    }
    
    // MARK: - recommendedVersion(characterCount:mode:errorCorrectionLevel:)
    
    @Test
    func recommendsVersion1AtConfigurationCapacity() {
        let analyzer = DataAnalyzer()
        
        let capacities: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 17),
            (.alphanumeric, 10),
            (.kanji, 4),
            (.byte, 7)
        ]
        
        for capacity in capacities {
            let version = analyzer.recommendedVersion(
                characterCount: capacity.characterCount,
                mode: capacity.mode,
                errorCorrectionLevel: .H
            )
            
            #expect(version == .v1)
        }
    }
    
    @Test
    func recommendsNextVersionWhenPreviousCapacityExceeded() {
        let analyzer = DataAnalyzer()
        
        let characterCounts: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 235 + 1),
            (.alphanumeric, 143 + 1),
            (.kanji, 60 + 1),
            (.byte, 98 + 1)
        ]
        
        for value in characterCounts {
            let version = analyzer.recommendedVersion(
                characterCount: value.characterCount,
                mode: value.mode,
                errorCorrectionLevel: .H
            )
            
            #expect(version == .v10)
        }
    }
    
    @Test
    func returnsNoRecommendedVersionAboveMaximumCapacity() {
        let analyzer = DataAnalyzer()
        
        let exceedingCounts: [(mode: EncodingMode, characterCount: Int)] = [
            (.numeric, 7089 + 1),
            (.alphanumeric, 4296 + 1),
            (.kanji, 1817 + 1),
            (.byte, 2953 + 1)
        ]
        
        for value in exceedingCounts {
            let version = analyzer.recommendedVersion(
                characterCount: value.characterCount,
                mode: value.mode,
                errorCorrectionLevel: .min
            )
            
            #expect(version == nil)
        }
    }
    
    // MARK: - maximizeErrorCorrectionLevel(characterCount:mode:version:)
    
    @Test
    func maximizesErrorCorrectionLevel() {
        let analyzer = DataAnalyzer()
        
        let cases: [(characterCount: Int, expectedLevel: ErrorCorrectionLevel)] = [
            (7, .H),
            (7 + 1, .Q),
            (11 + 1, .M),
            (14 + 1, .L)
        ]
        
        for testCase in cases {
            let level = analyzer.maximizeErrorCorrectionLevel(
                characterCount: testCase.characterCount,
                mode: .byte,
                version: .v1
            )
            
            #expect(level == testCase.expectedLevel)
        }
    }
    
    @Test
    func returnsNoErrorCorrectionLevelAboveVersionCapacity() {
        let analyzer = DataAnalyzer()
        
        let level = analyzer.maximizeErrorCorrectionLevel(
            characterCount: 18,
            mode: .byte,
            version: .v1
        )
        
        #expect(level == nil)
    }
}
