//
//  ViewController.swift
//  SoundVisualizer
//
//  Created by hongjuyeon_dev on 2020/04/23.
//  Copyright © 2020 hongjuyeon_dev. All rights reserved.
//
// ref: https://medium.com/swlh/swiftui-create-a-sound-visualizer-cadee0b6ad37

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var visualizeView: UIView!
    
    private var mic: MicrophoneMonitor?
    
    var recordValueArray = [Float](repeating: .zero, count: 10) {
        didSet {
            let value = recordValueArray.map { self.normalizeRecordValue(level: $0) }
            print("**** soundSamples: \(recordValueArray) \n normalizedSamples: \(value)")
            DispatchQueue.main.async {
                self.addWaveView(values: value)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mic = MicrophoneMonitor(numberOfSamples: 10, vc: self)
    }
    
    deinit {
        stopRecord()
    }

    // convert raw level sound
    private func normalizeRecordValue(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        let maxHeight = visualizeView.frame.size.height
        
        return CGFloat(level * (maxHeight / 25))
    }
    
    private func addWaveView(values: [CGFloat]) {
        for subview in visualizeView.subviews {
            subview.removeFromSuperview()
        }
        
        var xPos: CGFloat = 0.0
        for i in 0..<values.count {
            let bar = UIView()
            let width = (UIScreen.main.bounds.width - 30.0 - 30.0 - 90) / 10.0
            let height = values[i]
            bar.frame = CGRect(x: xPos, y: (visualizeView.frame.size.height - height) / 2, width: width, height: height)
            bar.backgroundColor = .purple
            visualizeView.addSubview(bar)
            
            xPos += width
            xPos += 10
        }
    }
    
    private func stopRecord() {
        self.mic?.audioRecorder.stop()
        self.mic?.timer?.invalidate()
        self.mic = nil
    }
}

