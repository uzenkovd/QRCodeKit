//
//  QRMask.swift
//  QRCodeKit
//
//  Created by Dmytro Uzenkov on 11.08.2026.
//

public enum QRMask: Int, Sendable {
    case pattern0 = 0
    case pattern1
    case pattern2
    case pattern3
    case pattern4
    case pattern5
    case pattern6
    case pattern7
    
    public static let `default`: QRMask = .pattern0
}
