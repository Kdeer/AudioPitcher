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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordedAudios.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel!.text = recordedAudios[indexPath.row].title
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("SoundMixViewController") as! SoundMixViewController
        controller.receivedAudio = recordedAudios[indexPath.row]
        self.presentViewController(controller, animated: true, completion: nil)
//        self.navigationController!.showViewController(controller, sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(editingStyle) {
        case .Delete:
            let audio = recordedAudios[indexPath.row]


            let path = pathForIdentifier(recordedAudios[indexPath.row].title)
            
            do {
               try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch _{}
    
            sharedContext.deleteObject(audio)
            saveContext()
            recordedAudios.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            saveContext()
        default:
            break
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
}

extension RecordSoundsViewController {
    
    func hideAndShow(theNumber: Int) {
        
        if theNumber == 1 {
            pausebutton.hidden = true
            recordingAudio.enabled = true
            start.hidden = false
            resumerecord.hidden = true
            recording.hidden = true
            stopbutton.hidden = true
            pause.hidden = true
        }else if theNumber == 2 {
            pausebutton.hidden = false
            start.hidden = true
            recordingAudio.enabled = false
            recording.hidden = false
            stopbutton.hidden = false
        }else if theNumber == 3 {
            pause.hidden = false
            audioRecorder.pause()
            resumerecord.hidden = false
            stopbutton.hidden = false
            pausebutton.hidden = true
            recording.hidden = true
        }else if theNumber == 4 {
            recording.hidden = false
            pause.hidden = true
            pausebutton.hidden = false
            resumerecord.hidden = true
            stopbutton.hidden = false
            audioRecorder.record()
        }else if theNumber == 5 {
            pause.hidden = true
            pausebutton.hidden = true
            audioRecorder.stop()
            recording.hidden = true
            recordingAudio.enabled = true
            stopbutton.hidden = true
            start.hidden = false
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
        
        
        
    }
    
    
    
    
    
    
}