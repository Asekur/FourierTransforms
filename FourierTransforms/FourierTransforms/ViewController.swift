//
//  ViewController.swift
//  FourierTransforms
//
//  Created by Chegelik on 14.11.2021.
//

import Cocoa
import Charts

class ViewController: NSViewController {
    @IBOutlet weak var signalChart: LineChartView!
    @IBOutlet weak var amplitudesChart: LineChartView!
    @IBOutlet weak var phasesChart: LineChartView!
    
    @IBOutlet weak var excludingPhasesCheck: NSButton!
    @IBOutlet weak var fastFourierCheck: NSButton!
    @IBOutlet weak var signalSegmentControl: NSSegmentedControl!
    
    @IBOutlet weak var phaseField: NSTextField!
    @IBOutlet weak var frequencyField: NSTextField!
    @IBOutlet weak var amplitudeField: NSTextField!
    
    private let chartColor = NSColor(calibratedRed: 0.2, green: 0.1, blue: 0.4, alpha: 1).cgColor
    private let chartRestoredColor = NSColor(calibratedRed: 1.0, green: 0.1, blue: 0.1, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func spectrGraphics(spectr: ([Double], [Double])) {
        for i in 0..<Constants.frameCount {
            self.appendData(chart: amplitudesChart, data: ChartDataEntry(x: Double(i), y: spectr.0[i]))
            self.appendData(chart: phasesChart, data: ChartDataEntry(x: Double(i), y: spectr.1[i]))
        }
    }
    
    func harmonicGraphics() {
        let cosData = createSignal(amplitude: amplitudeField.doubleValue, frequency: frequencyField.doubleValue, phase: phaseField.doubleValue)
        let data = SignalHarmonic(data: cosData)
        let ft = fastFourierCheck.state == .on ? data.getFFT(parts: data.getFFTParts(data: cosData)) : data.getDFT()
        
        let restored = data.restore(amplitudes: ft.0, phases: ft.1)
        self.compareSignals(initValues: cosData, restoredValues: restored)
        
        spectrGraphics(spectr: ft)
        
    }
    
    func polyharmonicGraphics() {
        let polyData = createSignalPolyharmonic()
        let data = SignalPolyharmonic(data: polyData)
        let ft = fastFourierCheck.state == .on ? data.getFFT(parts: data.getFFTParts(data: polyData)) : data.getDFT()
        
        let restored = data.restore(amplitudes: ft.0, phases: ft.1, excludingPhases: excludingPhasesCheck.state == .on)
        self.compareSignals(initValues: polyData, restoredValues: restored)
        
        spectrGraphics(spectr: ft)
    }
 
    @IBAction func generateClicked(_ sender: Any) {
        clearValues()
        setupUI()
        switch signalSegmentControl.indexOfSelectedItem {
            case 0:
                harmonicGraphics()
            case 1:
                polyharmonicGraphics()
            default:
                fatalError()
        }
    }
    
    private func clearValues() {
        self.signalChart.clearValues()
        self.amplitudesChart.clearValues()
        self.phasesChart.clearValues()
    }
    
    private func createSignal(amplitude: Double, frequency: Double, phase: Double) -> [Double] {
        var data = [Double]()
        for i in 0..<Constants.frameCount {
            let angle = (2 * Double.pi * Double(i) * frequency / Double(Constants.frameCount)) + phase
            let value = amplitude * cos(angle)
            data.append(value)
        }
        return data
    }
    
    private func createSignalPolyharmonic() -> [Double] {
        var signal = [Double]()
        for i in 0..<Constants.frameCount {
            var tempPolyharmonic = 0.0
            let amplitude = Constants.randomAmplitudes[Int.random(in: 0..<Constants.randomAmplitudes.count)]
            let phase = Constants.randomPhases[Int.random(in: 0..<Constants.randomPhases.count)]
            for j in 1..<Constants.amountHarmonics {
                let angle = (2 * Double.pi * Double(i) * Double(j) / Double(Constants.frameCount)) - phase
                let value = amplitude * cos(angle)
                tempPolyharmonic += value
            }
            signal.append(tempPolyharmonic)
        }
        return signal
    }
    
    private func setupUI() {
        self.setupChart(chart: signalChart)
        self.setupChart(chart: amplitudesChart)
        self.setupChart(chart: phasesChart)
        self.setData(chart: signalChart, isAmplitude: false)
        self.setData(chart: amplitudesChart, isAmplitude: true)
        self.setData(chart: phasesChart, isAmplitude: false)
    }
    
    //настройка графика
    private func setupChart(chart: LineChartView) {
        chart.rightAxis.enabled = false
        chart.dragEnabled = true
        chart.doubleTapToZoomEnabled = false
        
        let yAxis =  chart.leftAxis
        yAxis.drawGridLinesEnabled = false
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.valueFormatter = DefaultAxisValueFormatter(decimals: 100)
        
        let xAxis =  chart.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.labelPosition = .bottom
        
        chart.animate(xAxisDuration: 0.5, easingOption: .linear)
    }
    
    //установка данных на график
    private func setData(chart: LineChartView, isAmplitude: Bool) {
        let set = getDataSet(color: chartColor, label: "Signal", alpha: 0.3)
        set.label = isAmplitude ? "Amplitudes" : "Phases"
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        chart.data = data
    }
    
    //настройка линий
    private func getDataSet(color: CGColor, label: String, alpha: Double) -> LineChartDataSet {
        let set = LineChartDataSet(label: label)
        set.mode = .linear
        set.drawCirclesEnabled = false
        set.drawFilledEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.fill = Fill(color: (NSUIColor(cgColor: color) ?? .blue))
        set.fillAlpha = CGFloat(alpha)
        set.highlightColor = .clear
        set.lineWidth = 2
        set.setColor(NSUIColor(cgColor: color) ?? .blue)
        return set
    }
}

// MARK: - SignalDelegate
extension ViewController {
    func appendData(chart: LineChartView, data: ChartDataEntry) {
        DispatchQueue.main.async {
            chart.data?.addEntry(data, dataSetIndex: 0)
            chart.notifyDataSetChanged()
        }
    }
    
    func compareSignals(initValues: [Double], restoredValues: [Double]) {
        func addEntries(for set: LineChartDataSet, values: [Double]) {
            for (i, value) in values.enumerated() {
                set.append(ChartDataEntry(x: Double(i), y: value))
            }
        }
            
        let initSet = self.getDataSet(color: self.chartColor, label: "Initial Signal", alpha: 0.5)
        let restoredSet = self.getDataSet(color: self.chartRestoredColor, label: "Restored Signal", alpha: 0.5)
            
        addEntries(for: initSet, values: initValues)
        addEntries(for: restoredSet, values: restoredValues)
        self.signalChart.data = LineChartData(dataSets: [initSet, restoredSet])
    }
}

