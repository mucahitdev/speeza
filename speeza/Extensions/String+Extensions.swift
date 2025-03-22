//
//  String+Extensions.swift
//  speeza
//
//  Created by Mücahit Kökdemir NTT on 20.03.2025.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
