//
//  SoundMixViewController.swift
//  test01
//
//  Created by Xiaochao Luo on 2016-06-15.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SoundMixViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    var myTimer: NSTimer = NSTimer()
    var destinyNumber: String! = nil
    
    var playerNode: AVAudioPlayerNode! = AVAudioPlayerNode()
    var currentTime: Double = 0
    var theType: String! = nil
    let chipmunkSliderValueKey = "ChipMunk Value Key"
    let rateSliderValueKey = "rate Value Key"
    
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var chipmunkTextField: UITextField!
    @IBOutlet weak var sliderValue: UISlider!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var sliderRateValue: UISlider!
    @IBOutlet weak var chipmunkRate: UISlider!
    
    @IBOutlet weak var audioRate: UISlider!
    
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var darthVaderButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var chipmunkLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        destinyNumber = "stop"
        errorLabel.hidden = true
        pauseButton.hidden = true
        if chipmunkRate.value >= 0 {
            darthVaderButton.hidden = true
            chipmunkButton.hidden = false
        }else {
            chipmunkButton.hidden = true
            darthVaderButton.hidden = false
        }
        if audioRate.value >= 1 {
            slowButton.hidden = true
            fastButton.hidden = false
        }else {
            fastButton.hidden = true
            slowButton.hidden = false
        }
        chipmunkLabel.text = "\(chipmunkRate.value)"
        rateLabel.text = "\(audioRate.value)"
        showTimeLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipmunkTextField.delegate = self
        rateTextField.delegate = self
        
        let filePath = pathForIdentifier(receivedAudio.title)
        
        audioPlayer = try! AVAudioPlayer(contentsOfURL: NSURL(string: filePath)!)
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: NSURL(string: filePath)!)
        
        sliderValue.maximumValue = Float(audioPlayer.duration)
        
        chipmunkRate.value = NSUserDefaults.standardUserDefaults().floatForKey(chipmunkSliderValueKey)
        
        if NSUserDefaults.standardUserDefaults().floatForKey(rateSliderValueKey) == 0 {
            audioRate.value = 1
        }else {
        audioRate.value = NSUserDefaults.standardUserDefaults().floatForKey(rateSliderValueKey)
        }
        
    }
    
    @IBAction func Return(sender: AnyObject) {
        audioPlayer.stop()
        myTimer.invalidate()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    //mark: startButton
    @IBAction func PlayAudio(sender: AnyObject) {
        

        startButton.hidden = true
        pauseButton.hidden = false
        if destinyNumber == "pause" {
            playerNode.play()
            myTimer.invalidate()
            chipmunkSoundProgress1(chipmunkRate.value, rate: audioRate.value)
        } else {
            self.currentTime = 0
            myTimer.invalidate()
        chipmunkSound1(chipmunkRate.value, rate: audioRate.value)
            destinyNumber = "playing"
        NSUserDefaults.standardUserDefaults().setFloat(chipmunkRate.value, forKey: chipmunkSliderValueKey)
        NSUserDefaults.standardUserDefaults().setFloat(audioRate.value, forKey: rateSliderValueKey)
        }

    }
    
    //mark: Slider Bar movement for audio Timer
    
    @IBAction func SliderBarMovement(sender: AnyObject) {
        self.currentTime = Double(sliderValue.value)
        myTimer.invalidate()
        startButton.hidden = true
        pauseButton.hidden = false
        
        self.chipmunkSoundProgressF(chipmunkRate.value, rate: audioRate.value)
    }
    
    @IBAction func RateMovement(sender: AnyObject) {

        rateLabel.text = "\(audioRate.value)"
        if destinyNumber == "playing" {
        myTimer.invalidate()

        chipmunkSoundProgress1(chipmunkRate.value, rate: audioRate.value)
        }
        if audioRate.value >= 1 {
            slowButton.hidden = true
            fastButton.hidden = false
        }else {
            fastButton.hidden = true
            slowButton.hidden = false
        }
        NSUserDefaults.standardUserDefaults().setFloat(audioRate.value, forKey: rateSliderValueKey)

    }
    
    @IBAction func pauseAction(sender: AnyObject) {
        playerNode.pause()
        startButton.hidden = false
        pauseButton.hidden = true
        destinyNumber = "pause"
    }
    
    
    
    @IBAction func stopbutton(sender: UIButton) {
        startButton.hidden = false
        pauseButton.hidden = true
        myTimer.invalidate()
        audioEngine.stop()
        audioEngine.reset()
        sliderValue.value = 0
        destinyNumber = "stop"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func chipmunkMovement(sender: AnyObject) {
        chipmunkLabel.text = "\(chipmunkRate.value)"
        if destinyNumber == "playing" {
        playerNode.play()
        myTimer.invalidate()
        chipmunkSoundProgress1(chipmunkRate.value, rate: audioRate.value)
        }
        if chipmunkRate.value >= 0 {
            darthVaderButton.hidden = true
            chipmunkButton.hidden = false
        }else {
            chipmunkButton.hidden = true
            darthVaderButton.hidden = false
        }
        NSUserDefaults.standardUserDefaults().setFloat(chipmunkRate.value, forKey: chipmunkSliderValueKey)

    }
    
    func chipmunkSound1(SoundValue: Float, rate: Float){
        let filePath = pathForIdentifier(receivedAudio.title)
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: NSURL(string: filePath)!)
        
        playerNode.stop()
        audioEngine.stop()
        audioEngine.reset()

        
        audioEngine.attachNode(playerNode)
        let changeAudioUnitTime = AVAudioUnitTimePitch()
        
        changeAudioUnitTime.pitch = SoundValue
        changeAudioUnitTime.rate = rate
        audioEngine.attachNode(changeAudioUnitTime)
        audioEngine.connect(playerNode, to: changeAudioUnitTime, format: nil)
        audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
        playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        try! audioEngine.start()
        
        playerNode.play()
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SoundMixViewController.currentTime1), userInfo: nil, repeats: true)
    }
    
    func chipmunkSoundProgress1(SoundValue: Float, rate: Float) {
                let filePath = pathForIdentifier(receivedAudio.title)
        
                audioEngine = AVAudioEngine()
                audioFile = try! AVAudioFile(forReading: NSURL(string: filePath)!)
        
                audioEngine.stop()
                audioEngine.reset()
        
                audioEngine.attachNode(playerNode)
                let changeAudioUnitTime = AVAudioUnitTimePitch()
                changeAudioUnitTime.pitch = SoundValue
        changeAudioUnitTime.rate = rate
                audioEngine.attachNode(changeAudioUnitTime)
                audioEngine.connect(playerNode, to: changeAudioUnitTime, format: nil)
                audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
                playerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
                try! audioEngine.start()
                let nodeTime = playerNode.lastRenderTime!
        let playerTime = playerNode.playerTimeForNodeTime(nodeTime)!
        let sampleRate = playerTime.sampleRate
        let newSampleTime = AVAudioFramePosition(sampleRate*Double(sliderValue.value)
        )
        let length = Float(audioPlayer.duration) - sliderValue.value
        let frameStopPlay = AVAudioFrameCount(Float(playerTime.sampleRate)*length)
        playerNode.stop()
        if frameStopPlay > 100 {
            playerNode.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: frameStopPlay, atTime: nil, completionHandler: nil)
        }
        playerNode.play()
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SoundMixViewController.currentTime1), userInfo: nil, repeats: true)
    }
    
    func showTimeLabel(){
        let minutes = Int(round(audioPlayer.duration))/60
        let seconds = Int(round(audioPlayer.duration)) - minutes*60
        timeLabel.text = NSString(format: "%02d:%02d", minutes,seconds) as String
           print(audioPlayer.duration)
    
    }
    
    func currentTime1() -> NSTimeInterval {
        
        if  let nodeTime: AVAudioTime = playerNode.lastRenderTime, playerTime: AVAudioTime = playerNode.playerTimeForNodeTime(nodeTime) {
            let currentTime = Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
            self.currentTime += 0.5*Double(audioRate.value)
            sliderValue.value = Float(self.currentTime)
            let minutes = Int(self.currentTime)/60
            let seconds = Int(self.currentTime) - minutes*60
            print(seconds)
            timeLabel.text = NSString(format: "%02d:%02d", minutes,seconds) as String
            if self.sliderValue.value == Float(audioPlayer.duration){
                playerNode.stop()
                myTimer.invalidate()
                sliderValue.value = 0
                startButton.hidden = false
                destinyNumber = "stop"
                pauseButton.hidden = true

            }

            return currentTime
        }
        return 0
    }
    
    func commonAudioFunction(audioChangeNumber: Float, typeOfChange: String){
        // this function was initially found on swift and learner's blog, then I edited a bit.
        //https://swiftios8dev.wordpress.com/2015/03/05/sound-effects-using-avaudioengine/
        
        
        //Mark: WOW ! above there, I am such an honest boy!!!
        
        
        let audioPlayerNode = AVAudioPlayerNode()
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        
        audioEngine.attachNode(audioPlayerNode)
        
        let changeAudioUnitTime = AVAudioUnitTimePitch()
        let reverbeffect = AVAudioUnitReverb()
        
        if (typeOfChange == "rate") {
            changeAudioUnitTime.rate = audioChangeNumber
            audioEngine.attachNode(changeAudioUnitTime)
            audioEngine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
            audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
            
        } else if(typeOfChange == "pitch"){
            changeAudioUnitTime.pitch = audioChangeNumber
            audioEngine.attachNode(changeAudioUnitTime)
            audioEngine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
            audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
        }else{
            reverbeffect.wetDryMix = audioChangeNumber
            audioEngine.attachNode(reverbeffect)
            audioEngine.connect(audioPlayerNode, to: reverbeffect, format: nil)
            audioEngine.connect(reverbeffect, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
            
        }
    }
}
