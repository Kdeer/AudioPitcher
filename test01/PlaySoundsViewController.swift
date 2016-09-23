//
//  PlaySoundsViewController.swift
//  test01
//
//  Created by Iris on 2015-12-09.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    @IBOutlet weak var sliderValue: UISlider!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let filePath = pathForIdentifier(receivedAudio.title)
        
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(string: filePath)!)
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: URL(string: filePath)!)
        
        sliderValue.maximumValue = Float(audioPlayer.duration)
        

        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string:receivedAudio.filePathUrl)!)
//        } catch _ {
//            audioPlayer = nil
//        }
//        audioPlayer.enableRate = true
//        
//        audioEngine = AVAudioEngine()
//        do {
//            audioFile = try AVAudioFile(forReading: NSURL(string:receivedAudio.filePathUrl)!)
//        } catch _ {
//            audioFile = nil
//        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func Return(_ sender: AnyObject) {
        audioPlayer.stop()
        Timer.cancelPreviousPerformRequests(withTarget: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func pitchSlider(_ sender: AnyObject) {
        
        
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(sliderValue.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlaySoundsViewController.updateSlider), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slowplay(_ sender: UIButton) {
       commonAudioFunction((0.5), typeOfChange: "rate")
    }

    @IBAction func fastplay(_ sender: UIButton) {
        commonAudioFunction(1.5, typeOfChange: "rate")
    }
    
    @IBAction func chipmunk(_ sender: UIButton) {
        let pitch = sliderValue.value
        commonAudioFunction(pitch, typeOfChange: "pitch")
//        audioPlayer.currentTime = 5.0
    }
    
    @IBAction func darthvader(_ sender: UIButton) {
        commonAudioFunction(-1000, typeOfChange: "pitch")
    }
    
    @IBAction func reverbsound(_ sender: UIButton) {
        commonAudioFunction(50, typeOfChange: "reverb")
        
    }
    
    
    func commonAudioFunction(_ audioChangeNumber: Float, typeOfChange: String){
        // this function was initially found on swift and learner's blog, then I edited a bit.
        //https://swiftios8dev.wordpress.com/2015/03/05/sound-effects-using-avaudioengine/
        
        
        //Mark: WOW ! above there, I am such an honest boy!!!
        
        
        let audioPlayerNode = AVAudioPlayerNode()
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.stop()
        audioPlayer.currentTime = 3.0
        
        audioEngine.attach(audioPlayerNode)
        
        let changeAudioUnitTime = AVAudioUnitTimePitch()
        let reverbeffect = AVAudioUnitReverb()
        
        if (typeOfChange == "rate") {
            changeAudioUnitTime.rate = audioChangeNumber
            audioEngine.attach(changeAudioUnitTime)
            audioEngine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
            audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
            
        } else if(typeOfChange == "pitch"){
            changeAudioUnitTime.pitch = audioChangeNumber
            audioEngine.attach(changeAudioUnitTime)
            audioEngine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
            audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
        }else{
            reverbeffect.wetDryMix = audioChangeNumber
            audioEngine.attach(reverbeffect)
            audioEngine.connect(audioPlayerNode, to: reverbeffect, format: nil)
            audioEngine.connect(reverbeffect, to: audioEngine.outputNode, format: nil)
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            try! audioEngine.start()
            
            audioPlayerNode.play()
        
    }
    }
    
    @IBAction func stopbutton(_ sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
        sliderValue.value = 0
    }
    
    func updateSlider() {
        sliderValue.value = Float(audioPlayer.currentTime)
        
        NSLog("\(sliderValue.value)")
    }
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL.path
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
