//
//  MicrophoneMonitor.swift
//  SoundVisualizer
//
//  Created by hongjuyeon_dev on 2020/04/24.
//  Copyright © 2020 hongjuyeon_dev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class MicrophoneMonitor {
    var audioRecorder = AVAudioRecorder()
    var timer: Timer?
    
    private var currentSample: Int
    private var numberOfSamples: Int
    
    var visualizeVC: UIViewController?
    
    var soundSamples: [Float]
    
    init(numberOfSamples: Int, view: UIView) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        self.visualizeView = view
        
        setupAudioSession()
    }
    
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission({ (isGranted) in
                if !isGranted {
                    fatalError("You must allow audio recording for this event to work")
                }
            })
        }
        
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
           audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            } else {
                try audioSession.setCategory(.playAndRecord, options: [])
            }
            
            self.startMonitoring()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        // record start
        audioRecorder.record()
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
                self.updateRecordValues()
            })
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateRecordValues), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateRecordValues() {
        self.audioRecorder.updateMeters()
        // sound sample array
        self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
        self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        
        if let vc = visualizeVC, vc.isKind(of: ViewController.self) {
            let resultVC = vc as! ViewController
            resultVC.recordValueArray = self.soundSamples
        }
    }
}
