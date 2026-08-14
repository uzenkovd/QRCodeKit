//
//  CharacterCapacities.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 13.08.2026.
//

struct CharacterCapacity {
    let numeric: Int
    let alphanumeric: Int
    let byte: Int
    let kanji: Int

    init(_ numeric: Int, _ alphanumeric: Int, _ byte: Int, _ kanji: Int) {
        self.numeric = numeric
        self.alphanumeric = alphanumeric
        self.byte = byte
        self.kanji = kanji
    }
}

enum CharacterCapacities {
    static func maxCapacity(for encodingMode: EncodingMode) -> Int {
        capacity(
            version: .max,
            errorCorrectionLevel: .min,
            encodingMode: encodingMode
        )
    }
    
    static func capacity(
        version: QRVersion,
        errorCorrectionLevel: ErrorCorrectionLevel,
        encodingMode: EncodingMode
    ) -> Int {
        guard let capacities = table[version]?[errorCorrectionLevel] else {
            preconditionFailure(
                "Character capacity is missing for \(version) and \(errorCorrectionLevel)"
            )
        }
        
        switch encodingMode {
        case .numeric:      return capacities.numeric
        case .alphanumeric: return capacities.alphanumeric
        case .kanji:        return capacities.kanji
        case .byte:         return capacities.byte
        }
    }
}

private extension CharacterCapacities {
    static let table: [QRVersion: [ErrorCorrectionLevel: CharacterCapacity]] = [
        .v1: [
            .L: CharacterCapacity(41, 25, 17, 10),
            .M: CharacterCapacity(34, 20, 14, 8),
            .Q: CharacterCapacity(27, 16, 11, 7),
            .H: CharacterCapacity(17, 10, 7, 4)
        ],
        .v2: [
            .L: CharacterCapacity(77, 47, 32, 20),
            .M: CharacterCapacity(63, 38, 26, 16),
            .Q: CharacterCapacity(48, 29, 20, 12),
            .H: CharacterCapacity(34, 20, 14, 8)
        ],
        .v3: [
            .L: CharacterCapacity(127, 77, 53, 32),
            .M: CharacterCapacity(101, 61, 42, 26),
            .Q: CharacterCapacity(77, 47, 32, 20),
            .H: CharacterCapacity(58, 35, 24, 15)
        ],
        .v4: [
            .L: CharacterCapacity(187, 114, 78, 48),
            .M: CharacterCapacity(149, 90, 62, 38),
            .Q: CharacterCapacity(111, 67, 46, 28),
            .H: CharacterCapacity(82, 50, 34, 21)
        ],
        .v5: [
            .L: CharacterCapacity(255, 154, 106, 65),
            .M: CharacterCapacity(202, 122, 84, 52),
            .Q: CharacterCapacity(144, 87, 60, 37),
            .H: CharacterCapacity(106, 64, 44, 27)
        ],
        .v6: [
            .L: CharacterCapacity(322, 195, 134, 82),
            .M: CharacterCapacity(255, 154, 106, 65),
            .Q: CharacterCapacity(178, 108, 74, 45),
            .H: CharacterCapacity(139, 84, 58, 36)
        ],
        .v7: [
            .L: CharacterCapacity(370, 224, 154, 95),
            .M: CharacterCapacity(293, 178, 122, 75),
            .Q: CharacterCapacity(207, 125, 86, 53),
            .H: CharacterCapacity(154, 93, 64, 39)
        ],
        .v8: [
            .L: CharacterCapacity(461, 279, 192, 118),
            .M: CharacterCapacity(365, 221, 152, 93),
            .Q: CharacterCapacity(259, 157, 108, 66),
            .H: CharacterCapacity(202, 122, 84, 52)
        ],
        .v9: [
            .L: CharacterCapacity(552, 335, 230, 141),
            .M: CharacterCapacity(432, 262, 180, 111),
            .Q: CharacterCapacity(312, 189, 130, 80),
            .H: CharacterCapacity(235, 143, 98, 60)
        ],
        .v10: [
            .L: CharacterCapacity(652, 395, 271, 167),
            .M: CharacterCapacity(513, 311, 213, 131),
            .Q: CharacterCapacity(364, 221, 151, 93),
            .H: CharacterCapacity(288, 174, 119, 74)
        ],
        .v11: [
            .L: CharacterCapacity(772, 468, 321, 198),
            .M: CharacterCapacity(604, 366, 251, 155),
            .Q: CharacterCapacity(427, 259, 177, 109),
            .H: CharacterCapacity(331, 200, 137, 85)
        ],
        .v12: [
            .L: CharacterCapacity(883, 535, 367, 226),
            .M: CharacterCapacity(691, 419, 287, 177),
            .Q: CharacterCapacity(489, 296, 203, 125),
            .H: CharacterCapacity(374, 227, 155, 96)
        ],
        .v13: [
            .L: CharacterCapacity(1022, 619, 425, 262),
            .M: CharacterCapacity(796, 483, 331, 204),
            .Q: CharacterCapacity(580, 352, 241, 149),
            .H: CharacterCapacity(427, 259, 177, 109)
        ],
        .v14: [
            .L: CharacterCapacity(1101, 667, 458, 282),
            .M: CharacterCapacity(871, 528, 362, 223),
            .Q: CharacterCapacity(621, 376, 258, 159),
            .H: CharacterCapacity(468, 283, 194, 120)
        ],
        .v15: [
            .L: CharacterCapacity(1250, 758, 520, 320),
            .M: CharacterCapacity(991, 600, 412, 254),
            .Q: CharacterCapacity(703, 426, 292, 180),
            .H: CharacterCapacity(530, 321, 220, 136)
        ],
        .v16: [
            .L: CharacterCapacity(1408, 854, 586, 361),
            .M: CharacterCapacity(1082, 656, 450, 277),
            .Q: CharacterCapacity(775, 470, 322, 198),
            .H: CharacterCapacity(602, 365, 250, 154)
        ],
        .v17: [
            .L: CharacterCapacity(1548, 938, 644, 397),
            .M: CharacterCapacity(1212, 734, 504, 310),
            .Q: CharacterCapacity(876, 531, 364, 224),
            .H: CharacterCapacity(674, 408, 280, 173)
        ],
        .v18: [
            .L: CharacterCapacity(1725, 1046, 718, 442),
            .M: CharacterCapacity(1346, 816, 560, 345),
            .Q: CharacterCapacity(948, 574, 394, 243),
            .H: CharacterCapacity(746, 452, 310, 191)
        ],
        .v19: [
            .L: CharacterCapacity(1903, 1153, 792, 488),
            .M: CharacterCapacity(1500, 909, 624, 384),
            .Q: CharacterCapacity(1063, 644, 442, 272),
            .H: CharacterCapacity(813, 493, 338, 208)
        ],
        .v20: [
            .L: CharacterCapacity(2061, 1249, 858, 528),
            .M: CharacterCapacity(1600, 970, 666, 410),
            .Q: CharacterCapacity(1159, 702, 482, 297),
            .H: CharacterCapacity(919, 557, 382, 235)
        ],
        .v21: [
            .L: CharacterCapacity(2232, 1352, 929, 572),
            .M: CharacterCapacity(1708, 1035, 711, 438),
            .Q: CharacterCapacity(1224, 742, 509, 314),
            .H: CharacterCapacity(969, 587, 403, 248)
        ],
        .v22: [
            .L: CharacterCapacity(2409, 1460, 1003, 618),
            .M: CharacterCapacity(1872, 1134, 779, 480),
            .Q: CharacterCapacity(1358, 823, 565, 348),
            .H: CharacterCapacity(1056, 640, 439, 270)
        ],
        .v23: [
            .L: CharacterCapacity(2620, 1588, 1091, 672),
            .M: CharacterCapacity(2059, 1248, 857, 528),
            .Q: CharacterCapacity(1468, 890, 611, 376),
            .H: CharacterCapacity(1108, 672, 461, 284)
        ],
        .v24: [
            .L: CharacterCapacity(2812, 1704, 1171, 721),
            .M: CharacterCapacity(2188, 1326, 911, 561),
            .Q: CharacterCapacity(1588, 963, 661, 407),
            .H: CharacterCapacity(1228, 744, 511, 315)
        ],
        .v25: [
            .L: CharacterCapacity(3057, 1853, 1273, 784),
            .M: CharacterCapacity(2395, 1451, 997, 614),
            .Q: CharacterCapacity(1718, 1041, 715, 440),
            .H: CharacterCapacity(1286, 779, 535, 330)
        ],
        .v26: [
            .L: CharacterCapacity(3283, 1990, 1367, 842),
            .M: CharacterCapacity(2544, 1542, 1059, 652),
            .Q: CharacterCapacity(1804, 1094, 751, 462),
            .H: CharacterCapacity(1425, 864, 593, 365)
        ],
        .v27: [
            .L: CharacterCapacity(3517, 2132, 1465, 902),
            .M: CharacterCapacity(2701, 1637, 1125, 692),
            .Q: CharacterCapacity(1933, 1172, 805, 496),
            .H: CharacterCapacity(1501, 910, 625, 385)
        ],
        .v28: [
            .L: CharacterCapacity(3669, 2223, 1528, 940),
            .M: CharacterCapacity(2857, 1732, 1190, 732),
            .Q: CharacterCapacity(2085, 1263, 868, 534),
            .H: CharacterCapacity(1581, 958, 658, 405)
        ],
        .v29: [
            .L: CharacterCapacity(3909, 2369, 1628, 1002),
            .M: CharacterCapacity(3035, 1839, 1264, 778),
            .Q: CharacterCapacity(2181, 1322, 908, 559),
            .H: CharacterCapacity(1677, 1016, 698, 430)
        ],
        .v30: [
            .L: CharacterCapacity(4158, 2520, 1732, 1066),
            .M: CharacterCapacity(3289, 1994, 1370, 843),
            .Q: CharacterCapacity(2358, 1429, 982, 604),
            .H: CharacterCapacity(1782, 1080, 742, 457)
        ],
        .v31: [
            .L: CharacterCapacity(4417, 2677, 1840, 1132),
            .M: CharacterCapacity(3486, 2113, 1452, 894),
            .Q: CharacterCapacity(2473, 1499, 1030, 634),
            .H: CharacterCapacity(1897, 1150, 790, 486)
        ],
        .v32: [
            .L: CharacterCapacity(4686, 2840, 1952, 1201),
            .M: CharacterCapacity(3693, 2238, 1538, 947),
            .Q: CharacterCapacity(2670, 1618, 1112, 684),
            .H: CharacterCapacity(2022, 1226, 842, 518)
        ],
        .v33: [
            .L: CharacterCapacity(4965, 3009, 2068, 1273),
            .M: CharacterCapacity(3909, 2369, 1628, 1002),
            .Q: CharacterCapacity(2805, 1700, 1168, 719),
            .H: CharacterCapacity(2157, 1307, 898, 553)
        ],
        .v34: [
            .L: CharacterCapacity(5253, 3183, 2188, 1347),
            .M: CharacterCapacity(4134, 2506, 1722, 1060),
            .Q: CharacterCapacity(2949, 1787, 1228, 756),
            .H: CharacterCapacity(2301, 1394, 958, 590)
        ],
        .v35: [
            .L: CharacterCapacity(5529, 3351, 2303, 1417),
            .M: CharacterCapacity(4343, 2632, 1809, 1113),
            .Q: CharacterCapacity(3081, 1867, 1283, 790),
            .H: CharacterCapacity(2361, 1431, 983, 605)
        ],
        .v36: [
            .L: CharacterCapacity(5836, 3537, 2431, 1496),
            .M: CharacterCapacity(4588, 2780, 1911, 1176),
            .Q: CharacterCapacity(3244, 1966, 1351, 832),
            .H: CharacterCapacity(2524, 1530, 1051, 647)
        ],
        .v37: [
            .L: CharacterCapacity(6153, 3729, 2563, 1577),
            .M: CharacterCapacity(4775, 2894, 1989, 1224),
            .Q: CharacterCapacity(3417, 2071, 1423, 876),
            .H: CharacterCapacity(2625, 1591, 1093, 673)
        ],
        .v38: [
            .L: CharacterCapacity(6479, 3927, 2699, 1661),
            .M: CharacterCapacity(5039, 3054, 2099, 1292),
            .Q: CharacterCapacity(3599, 2181, 1499, 923),
            .H: CharacterCapacity(2735, 1658, 1139, 701)
        ],
        .v39: [
            .L: CharacterCapacity(6743, 4087, 2809, 1729),
            .M: CharacterCapacity(5313, 3220, 2213, 1362),
            .Q: CharacterCapacity(3791, 2298, 1579, 972),
            .H: CharacterCapacity(2927, 1774, 1219, 750)
        ],
        .v40: [
            .L: CharacterCapacity(7089, 4296, 2953, 1817),
            .M: CharacterCapacity(5596, 3391, 2331, 1435),
            .Q: CharacterCapacity(3993, 2420, 1663, 1024),
            .H: CharacterCapacity(3057, 1852, 1273, 784)
        ]
    ]
}
