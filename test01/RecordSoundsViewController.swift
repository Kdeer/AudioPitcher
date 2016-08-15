//
//  RecordSoundsViewController.swift
//  test01
//
//  Created by Iris on 2015-12-09.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate{
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var recordedAudios: [RecordedAudio] = []
    var audioPlayer: AVAudioPlayer!
    
    
    @IBOutlet weak var recording: UILabel!
    @IBOutlet weak var stopbutton: UIButton!
    @IBOutlet weak var recordingAudio: UIButton!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var pausebutton: UIButton!
    @IBOutlet weak var pause: UILabel!
    @IBOutlet weak var resumerecord: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        
        recordedAudios = fetchAllPins()
//        print(recordedAudios[0].filePathUrl)
        self.tableView.reloadData()
        
    }
    
    func stopPlaying() {
        audioPlayer.stop()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                hideAndShow(1)
        
    }
    
    override func viewDidAppear(animated: Bool) {

//        tableView.delegate = self

    }

    @IBAction func recordingAudio(sender: UIButton) {
        hideAndShow(2)
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentdateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentdateTime)+".wave"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        //set up audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL:filePath!, settings: [:])
        
        audioRecorder.meteringEnabled = true
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        print("in audio")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            
            
            let alertController = UIAlertController(title: "Hello?", message: "Wanna rename the audio?", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler{(textField) in
                textField.placeholder = "Name"
            }
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .Default) {
                (action) in
                let renameTextField = alertController.textFields![0] as UITextField
                
                var repeated: Int = 0
                if self.recordedAudios.count > 0 {
                    for i in 0...self.recordedAudios.count-1 {
                        if renameTextField.text == self.recordedAudios[i].title || renameTextField.text! + "(\(repeated))" == self.recordedAudios[i].title{
                            repeated += 1
                        }
                    }
                }
                
                if repeated != 0 {
                    print(repeated)
                    renameTextField.text = renameTextField.text! + "(\(repeated))"
                }

                let dictionary: [String: AnyObject] = [
                    "title" : renameTextField.text!
                ]
                let pathWeDonotWant = self.pathForIdentifier("\(recorder.url.lastPathComponent!)")
                let pathWeWant = self.pathForIdentifier(renameTextField.text!)
                
                do {
                    try  NSFileManager.defaultManager().moveItemAtPath(pathWeDonotWant, toPath: pathWeWant)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                
                self.recordedAudio = RecordedAudio(dictionary: dictionary, context: self.sharedContext)
                self.recordedAudios.append(self.recordedAudio)
                self.saveContext()
                self.tableView.reloadData()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SoundMixViewController") as! SoundMixViewController
                controller.receivedAudio = self.recordedAudio
                self.presentViewController(controller, animated: true, completion: nil)
            }
            alertController.addAction(confirmAction)
            
            let keepAction = UIAlertAction(title: "Cancel", style: .Default){
                (action) in
                let dictionary: [String: AnyObject] = [
                    "title" : String(recorder.url.lastPathComponent!)
                ]
                
                self.recordedAudio = RecordedAudio(dictionary: dictionary, context: self.sharedContext)
                self.recordedAudios.append(self.recordedAudio)
                self.saveContext()
                self.tableView.reloadData()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SoundMixViewController") as! SoundMixViewController
                controller.receivedAudio = self.recordedAudio
                self.presentViewController(controller, animated: true, completion: nil)
                
            }
            
            alertController.addAction(keepAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }else{
            print("recording was not successful")
            recordingAudio.enabled = true
            stopbutton.hidden = true
            start.hidden = false
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as!RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func pausebutton(sender: UIButton) {
        hideAndShow(3)
    }
    
    @IBAction func resumerecord(sender: UIButton) {
        hideAndShow(4)
    }
    
    @IBAction func stopbutton(sender: UIButton) {
        hideAndShow(5)
    }
    
    func fetchAllPins() -> [RecordedAudio] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "RecordedAudio")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [RecordedAudio]
        } catch  let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [RecordedAudio]()
        }
    }
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
    
    //Mark: code to change the file's name
    
//    let fileManager = NSFileManager.defaultManager()
//    
//    // Rename 'hello.swift' as 'goodbye.swift'
//    
//    do {
//    try fileManager.moveItemAtPath("hello.swift", toPath: "goodbye.swift")
//    }
//    catch let error as NSError {
//    print("Ooops! Something went wrong: \(error)")
//    }
				
}

