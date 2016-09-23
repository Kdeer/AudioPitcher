//
//  EXSoundMix.swift
//  test01
//
//  Created by Xiaochao Luo on 2016-06-17.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension SoundMixViewController: UITextFieldDelegate {
    
    func chipmunkSoundProgressF(_ SoundValue: Float, rate: Float) {
        
                let filePath = pathForIdentifier(receivedAudio.title)
        
                audioEngine = AVAudioEngine()
                audioFile = try! AVAudioFile(forReading: URL(string: filePath)!)
        
                playerNode.stop()
                audioEngine.stop()
                audioEngine.reset()
                audioPlayer.stop()
        
                audioEngine.attach(playerNode)
                let changeAudioUnitTime = AVAudioUnitTimePitch()
        
                changeAudioUnitTime.pitch = SoundValue
        changeAudioUnitTime.rate = rate
                audioEngine.attach(changeAudioUnitTime)
                audioEngine.connect(playerNode, to: changeAudioUnitTime, format: nil)
                audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
                playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
                try! audioEngine.start()
        
                playerNode.play()
        let nodeTime = playerNode.lastRenderTime!
        
        let playerTime = playerNode.playerTime(forNodeTime: nodeTime)!
        let sampleRate = playerTime.sampleRate
        let newSampleTime = AVAudioFramePosition(sampleRate*Double(sliderValue.value)
        )
        let length = Float(audioPlayer.duration) - sliderValue.value
        let frameStopPlay = AVAudioFrameCount(Float(playerTime.sampleRate)*length)
        playerNode.stop()
        if frameStopPlay > 100 {
            playerNode.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: frameStopPlay, at: nil, completionHandler: nil)
        }
        playerNode.play()
        
        myTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SoundMixViewController.currentTime1), userInfo: nil, repeats: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if chipmunkTextField.isFirstResponder {
        if  Double(chipmunkTextField.text!) != nil && Double(chipmunkTextField.text!)  >= -1000 && Double(chipmunkTextField.text!) <= 1000{
            chipmunkRate.value = Float(chipmunkTextField.text!)!
            chipmunkLabel.text = chipmunkTextField.text
            UserDefaults.standard.set(chipmunkRate.value, forKey: chipmunkSliderValueKey)
            errorLabel.isHidden = true
        }else {
            errorLabel.isHidden = false
            errorLabel.text = "You Entered an Invalid Number"
            print("you cannot do that")
        }
        }
        
        if rateTextField.isFirstResponder {
        if Double(rateTextField.text!) != nil && Double(rateTextField.text!)  > 0 && Double(rateTextField.text!) <= 3 {
            sliderRateValue.value = Float(rateTextField.text!)!
            rateLabel.text = rateTextField.text
            UserDefaults.standard.set(audioRate.value, forKey: rateSliderValueKey)
            errorLabel.isHidden = true
        }else {
            errorLabel.isHidden = false
            errorLabel.text = "You Entered an Invalid Number"
            print("you cannot do that too")
        }
        }
        textField.resignFirstResponder()
        return true
    }
    
    func doubleCheck(_ textField: UITextField) -> Bool {
        
        if (Double(textField.text!) != nil) && Double(textField.text!)  > 0 && Double(textField.text!) < 3 {
            return true
        } else if (Double(textField.text!) != nil) && Double(textField.text!)  > -1000 && Double(textField.text!) < 1000 {
            return true
        }
        return false
    }
    
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL.path
    }
    
    
    
    
    
}

//func chipmunkSoundProgress() {
//    
//    let nodeTime = playerNode.lastRenderTime!
//    
//    let playerTime = playerNode.playerTimeForNodeTime(nodeTime)!
//    let sampleRate = playerTime.sampleRate
//    let newSampleTime = AVAudioFramePosition(sampleRate*Double(sliderValue.value)
//    )
//    let length = Float(audioPlayer.duration) - sliderValue.value
//    let frameStopPlay = AVAudioFrameCount(Float(playerTime.sampleRate)*length)
//    playerNode.stop()
//    if frameStopPlay > 100 {
//        playerNode.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: frameStopPlay, atTime: nil, completionHandler: nil)
//    }
//    playerNode.play()
//    
//    myTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SoundMixViewController.currentTime1), userInfo: nil, repeats: true)
//    
//}
