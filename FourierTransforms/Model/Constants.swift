//
//  Constants.swift
//  FourierTransforms
//
//  Created by Chegelik on 23.11.2021.
//

import Foundation

struct Constants {
    // MARK: - General properties
    static let frameCount = 1024
    static let randomAmplitudes = [1.0, 3.0, 5.0, 8.0, 10.0, 12.0, 16.0]
    static let randomPhases = [Double.pi / 6.0,
                               Double.pi / 4.0,
                               Double.pi / 3.0,
                               Double.pi / 2.0,
                               3.0 * Double.pi / 4.0,
                               Double.pi]
    static let amountHarmonics = 30
}
