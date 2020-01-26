//
//  DetailTaskViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-23.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class DetailTaskViewController: UIViewController, UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    
    var note = Note()
    var notesArray : [Note] = []
    var categoryPassed = ""
   
    //audio fucntionality
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    //audioplayer
    
    @IBOutlet var audioPlayerView: UIView!
    
    @IBOutlet var audioPlay: UIButton!
    
    @IBOutlet var recordingTitle: UILabel!
    
    
    
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var textTitle: UITextView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet var imageTask: UIImageView!
    @IBOutlet var labelDesc: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textTitle.delegate = self
        textTitle.textContainer.maximumNumberOfLines = 1
        //labelDesc.becomeFirstResponder()
        //textTitle.textContainer.lineBreakMode  = .byTruncatingTail
        
        //code after adding audio
        if note.audiopath.elementsEqual("")
        {
        audioPlayerView.isHidden = true
        }
        else
        {
            audioPlayerView.isHidden = false
        }
        
        
        
        
        textTitle.text = note.title
        labelDesc.text = note.desc
        let imgData = note.imageData
        imageTask.isHidden = true
        imageLabel.isHidden  = true
        if !(imgData.isEmpty)
        {
            imageTask.isHidden = false
            imageLabel.isHidden  = false
            
            let img = UIImage(data: imgData)
            imageTask.image = img
        }
        //textTitle.text = note.category
        

        // Do any additional setup after loading the view.
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? mapLocationViewController{
            newVC.lat = note.lat
            newVC.long = note.long
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        //self.resignFirstResponder()//        labelDesc.becomeFirstResponder()
        
        return linesAfterChange == textView.textContainer.maximumNumberOfLines
       
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print(categoryPassed)
        
        let title = textTitle.text
        let desc = labelDesc.text
        let date = note.createdAt
        let image = note.imageData
        let category = note.category
        let lat = note.lat
        let long = note.long
        let note1 = Note()
        note1.title = title!
        note1.desc = desc!
        note1.createdAt = date
        note1.imageData = image
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath:getFileUrl().path)
        {
           
            do{
                let path = getDocumentsDirectory()
                let originPath = path.appendingPathComponent(note.title+note.desc)
                print(originPath)
                let destinationPath = path.appendingPathComponent(title!+desc!)
                print(destinationPath)
                    try FileManager.default.moveItem(at: originPath, to: destinationPath)
                } catch {
                    print(error)
                }
            
        }
        note1.audiopath = note.audiopath
        print(note1.audiopath)
        note1.category = categoryPassed
        note1.lat = lat
        note1.long = long
        deleteData()
        //note.category = category
        print(category)
        print(note1.category)
        notesArray.removeAll()
        loadFromCoreData()
        notesArray.append(note1)
        saveToCoreData()
        
        
        
        
    }
    
    
    @IBAction func startRecording(_ sender: Any)
    {
        if(isRecording)
        {
            finishAudioRecording(success: true)
        //record_btn_ref.setTitle("Record", for: .normal)
            //play_btn_ref.isEnabled = true
            isRecording = false
            audioPlayerView.isHidden = false
            note.audiopath = "\(getFileUrl())"
            //print(note.audiopath)
            
        }
        else
        {
            check_record_permission()
            setup_recorder()

            audioRecorder.record()
            display_alert(msg_title: "recording", msg_desc: "app is now recording audio", action_title: "ok")
            
            //meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //record_btn_ref.setTitle("Stop", for: .normal)
            //play_btn_ref.isEnabled = false
            isRecording = true
        }
    }
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            //meterTimer.invalidate()
            print("recorded successfully.")
            
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl() -> URL
    {
        let name = note.title + note.desc
        let filename = name
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        print(filePath)
    return filePath
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
                
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    
    @IBAction func playBtn(_ sender: Any)
    {
        if(isPlaying)
               {
                   audioPlayer.stop()
                   //record_btn_ref.isEnabled = true
                   //play_btn_ref.setTitle("Play", for: .normal)
                   isPlaying = false
               }
               else
               {
                   if FileManager.default.fileExists(atPath: getFileUrl().path)
                   {
                       //record_btn_ref.isEnabled = false
                       //play_btn_ref.setTitle("pause", for: .normal)
                       prepare_play()
                       audioPlayer.play()
                       isPlaying = true
                   }
                   else
                   {
                       display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
                   }
               }
    }
    
    func prepare_play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func saveToCoreData()
    {
        //deleteData()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        for i in notesArray
        {
            newTask.setValue(i.title, forKey: "title")
            //newTask.setValue(Int16(i.noOfDays), forKey: "noOfDays")
            newTask.setValue(i.desc, forKey: "desc")
            newTask.setValue(i.category, forKey: "category")
            newTask.setValue(i.createdAt, forKey: "date")
            newTask.setValue(i.lat, forKey: "latitude")
            newTask.setValue(i.long, forKey: "longitude")
            newTask.setValue(i.imageData, forKey: "image")
            newTask.setValue(i.audiopath, forKey: "audiopath")

        
        
        do
                   {
                        try context.save()
                       print(newTask, "is saved")
                   }catch
                   {
                       print(error)
                   }
        }
        
    }
    
    func clearCoreData ()
       {

                  let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                         let context = appDelegate.persistentContainer.viewContext
                  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
           fetchRequest.returnsObjectsAsFaults = false
           do{
               let results = try context.fetch(fetchRequest)
               
               for managedObjects in results{
                   if let managedObjectsData = managedObjects as? NSManagedObject
                   {
                       context.delete(managedObjectsData)
                   }
               
               }
           }catch{
               print(error)
           }
       
       }
    func loadFromCoreData()
    {
      
     // self.clearCoreData()
      
      
      // new

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
              
               let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false

      
         
         if let result = try? context.fetch(fetchRequest) {
          for object in result as! [NSManagedObject] {
              
              
              let title = object.value(forKey: "title")
              let desc = object.value(forKey: "desc")
              let lat = object.value(forKey: "latitude")
              let long = object.value(forKey: "longitude")
              let image = object.value(forKey: "image")
            let category = object.value(forKey: "category")
            let audiopath = object.value(forKey: "audiopath")
    

              
              let note = Note()
              note.title = title as! String
              note.desc = desc as! String
              note.lat = lat as! Double
              note.long = long as! Double
              if (image != nil)
              {
              note.imageData  = image as! Data
              }
            if (audiopath != nil)
            {
                note.audiopath = audiopath as! String
            }
            
            note.category = category as! String
            
              
              
              notesArray.append(note)
             }
         }
      
      }
    func deleteData()
    {
        
                  // create an instance of app delegate
                  
                  let appDelegate = UIApplication.shared.delegate as! AppDelegate
                  
                   let context = appDelegate.persistentContainer.viewContext
               
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")

               fetchRequest.returnsObjectsAsFaults = false

               
               let predicate = NSPredicate(format: "title=%@", "\(note.title)")
               fetchRequest.predicate = predicate
               if let result = try? context.fetch(fetchRequest) {
                   for object in result {
                       context.delete(object as! NSManagedObject)
                   }
               }
              
                              
                                 do
                                 {
                                    try context.save()
                                 }
                                 catch{
                                     
                                     print("error")
                                 }
        
    }
    

    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
        //_ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }

}
