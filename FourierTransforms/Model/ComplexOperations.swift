//
//  ComplexOperations.swift
//  FourierTransforms
//
//  Created by Chegelik on 23.11.2021.
//

import Foundation

class ComplexOperations {
    static func mulComplex(left: (Double, Double), right: (Double, Double)) -> (Double, Double) {
        return (left.0 * right.0 - left.1 * right.1,
                left.0 * right.1 + left.1 * right.0)
    }
    
    static func addComplex(left: (Double, Double), right: (Double, Double)) -> (Double, Double) {
        return (left.0 + right.0,
                left.1 + right.1)
    }
    
    static func subComplex(left: (Double, Double), right: (Double, Double)) -> (Double, Double) {
        return (left.0 - right.0,
                left.1 - right.1)
    }
}
