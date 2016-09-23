//
//  EXRecordSounds.swift
//  test01
//
//  Created by Xiaochao Luo on 2016-06-13.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension RecordSoundsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordedAudios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel!.text = recordedAudios[(indexPath as NSIndexPath).row].title
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "SoundMixViewController") as! SoundMixViewController
        controller.receivedAudio = recordedAudios[(indexPath as NSIndexPath).row]
        self.present(controller, animated: true, completion: nil)
//        self.navigationController!.showViewController(controller, sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch(editingStyle) {
        case .delete:
            let audio = recordedAudios[(indexPath as NSIndexPath).row]


            let path = pathForIdentifier(identifier: recordedAudios[(indexPath as NSIndexPath).row].title)
            
            do {
               try FileManager.default.removeItem(atPath: path)
            }catch _{}
    
            sharedContext.delete(audio)
            saveContext()
            recordedAudios.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            saveContext()
        default:
            break
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
}

extension RecordSoundsViewController {
    
    func hideAndShow(_ theNumber: Int) {
        
        if theNumber == 1 {
            pausebutton.isHidden = true
            recordingAudio.isEnabled = true
            start.isHidden = false
            resumerecord.isHidden = true
            recording.isHidden = true
            stopbutton.isHidden = true
            pause.isHidden = true
        }else if theNumber == 2 {
            pausebutton.isHidden = false
            start.isHidden = true
            recordingAudio.isEnabled = false
            recording.isHidden = false
            stopbutton.isHidden = false
        }else if theNumber == 3 {
            pause.isHidden = false
            audioRecorder.pause()
            resumerecord.isHidden = false
            stopbutton.isHidden = false
            pausebutton.isHidden = true
            recording.isHidden = true
        }else if theNumber == 4 {
            recording.isHidden = false
            pause.isHidden = true
            pausebutton.isHidden = false
            resumerecord.isHidden = true
            stopbutton.isHidden = false
            audioRecorder.record()
        }else if theNumber == 5 {
            pause.isHidden = true
            pausebutton.isHidden = true
            audioRecorder.stop()
            recording.isHidden = true
            recordingAudio.isEnabled = true
            stopbutton.isHidden = true
            start.isHidden = false
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
        
    }
    
    
    
}
