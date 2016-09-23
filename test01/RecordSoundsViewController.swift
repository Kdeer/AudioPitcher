        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Pin")//
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                hideAndShow(1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

//        tableView.delegate = self

    }

    @IBAction func recordingAudio(sender: UIButton) {
        hideAndShow(2)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let currentdateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.string(from: currentdateTime as Date)+".wave"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        //set up audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(url:filePath!, settings: [:])
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        print("in audio")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            
            
            let alertController = UIAlertController(title: "Hello?", message: "Wanna rename the audio?", preferredStyle: .alert)
            alertController.addTextField{(textField) in
                textField.placeholder = "Name"
            }
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
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
                    "title" : renameTextField.text! as AnyObject
                ]
                let pathWeDonotWant = self.pathForIdentifier(identifier: "\(recorder.url.lastPathComponent)")
                let pathWeWant = self.pathForIdentifier(identifier: renameTextField.text!)
                
                do {
                    try  FileManager.default.moveItem(atPath: pathWeDonotWant, toPath: pathWeWant)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                
                self.recordedAudio = RecordedAudio(dictionary: dictionary, context: self.sharedContext)
                self.recordedAudios.append(self.recordedAudio)
                self.saveContext()
                self.tableView.reloadData()
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "SoundMixViewController") as! SoundMixViewController
                controller.receivedAudio = self.recordedAudio
                self.present(controller, animated: true, completion: nil)
            }
            alertController.addAction(confirmAction)
            
            let keepAction = UIAlertAction(title: "Cancel", style: .default){
                (action) in
                let dictionary: [String: AnyObject] = [
                    "title" : String(recorder.url.lastPathComponent) as AnyObject
                ]
                
                self.recordedAudio = RecordedAudio(dictionary: dictionary, context: self.sharedContext)
                self.recordedAudios.append(self.recordedAudio)
                self.saveContext()
                self.tableView.reloadData()
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "SoundMixViewController") as! SoundMixViewController
                controller.receivedAudio = self.recordedAudio
                self.present(controller, animated: true, completion: nil)
                
            }
            
            alertController.addAction(keepAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            print("recording was not successful")
            recordingAudio.isEnabled = true
            stopbutton.isHidden = true
            start.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC: PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as!RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
//    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "stopRecording"){
//            let playSoundsVC: PlaySoundsViewController = segue.destination as! PlaySoundsViewController
//            let data = sender as!RecordedAudio
//            playSoundsVC.receivedAudio = data
//        }
//    }
    
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
//        let fetchRequest = NSFetchRequest(entityName: "RecordedAudio")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecordedAudio")
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [RecordedAudio]
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
        let documentsDirectoryURL: NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL!.path
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

