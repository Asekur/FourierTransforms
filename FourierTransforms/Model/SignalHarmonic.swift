//
//  Signal.swift
//  FourierTransforms
//
//  Created by Chegelik on 14.11.2021.
//

import Foundation

class SignalHarmonic {
    // MARK: - Properties
    private var values = [Double]()
        
    // MARK: - Init
    init(data: [Double]) {
        self.values = data
    }
    
    // MARK: - Methods
    func getDFT() -> ([Double], [Double]) {
        var amplitudes = [Double]()
        var phases = [Double]()
        
        for j in 0..<Constants.frameCount {
            var tempRe = 0.0
            var tempIm = 0.0
            for i in 0..<values.count {
                let angle = (2.0 * Double.pi * Double(j) * Double(i)) / Double(Constants.frameCount)
                tempRe += values[i] * cos(angle)
                tempIm += values[i] * sin(angle)
            }
            let rePart = 2.0 / Double(Constants.frameCount) * tempRe
            let imPart = 2.0 / Double(Constants.frameCount) * tempIm
            amplitudes.append(hypot(rePart, imPart))
            phases.append(atan2(imPart, rePart))
        }
        return (amplitudes, phases)
    }
    
    func restore(amplitudes: [Double], phases: [Double]) -> [Double] {
        let length = Constants.frameCount / 2
        var restore = [Double]()
        
        for i in 0..<Constants.frameCount {
            var tempRestore = 0.0
            for j in 0..<length {
                let angle = ((2.0 * Double.pi * Double(j) * Double(i)) / Double(Constants.frameCount)) - phases[j]
                tempRestore += amplitudes[j] * cos(angle)
            }
            restore.append(tempRestore)
        }
        return restore
    }
    
    func getFFT(parts: [(Double, Double)]) -> ([Double], [Double]) {
        let mul = 2.0 / Double(Constants.frameCount)
        let amplitudes = parts.map({ mul * hypot($0.0, $0.1) })
        let phases = parts.map({ -atan2($0.1, $0.0) })
        
        return (amplitudes, phases)
    }
    
    func getFFTParts(data: [Double]) -> [(Double, Double)] {
        let length = data.count
        guard length > 1 else { return [(data[0], 0.0)] }
        guard length % 2 <= 0 else { return [] }

        let halfLength = length / 2
        var xEven = [Double]()
        var xOdd = [Double]()

        for i in 0..<halfLength {
            xEven.append(data[2 * i])
            xOdd.append(data[2 * i + 1])
        }
            
        let xEvenNext = getFFTParts(data: xEven)
        let xOddNext = getFFTParts(data: xOdd)
            
        var result = Array(repeating: (0.0, 0.0), count: Constants.frameCount)
        for i in 0..<halfLength {
            let t = ComplexOperations.mulComplex(left: getW(for: i, with: length), right: xOddNext[i])
            result[i] = ComplexOperations.addComplex(left: xEvenNext[i], right: t)
            result[i + halfLength] = ComplexOperations.subComplex(left: xEvenNext[i], right: t)
        }
            
        return result
    }
    
    //возвращает угол
    private func getW(for k: Int, with n: Int) -> (Double, Double) {
        let arg = -2.0 * Double.pi * Double(k) / Double(n)
        return (cos(arg), sin(arg))
    }
}
