//
//  AIHintResponse.swift
//  DVWordKit
//
//  Created by Ranga Reddy on 11/16/24.
//

public struct AIHintResponse: Codable, Sendable {
    public let hint: String

    public init(hint: String) {
        self.hint = hint
    }
}
