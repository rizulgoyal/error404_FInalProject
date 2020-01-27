//
//  AddNewNoteViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-22.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import Photos
import AVFoundation
import MediaPlayer


class AddNewNoteViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate {


   //audio fucntionality
   var audioRecorder: AVAudioRecorder!
   var audioPlayer : AVAudioPlayer!
   var meterTimer:Timer!
   var isAudioRecordingGranted: Bool!
   var isRecording = false
   var isPlaying = false
    @IBOutlet var durationLabel: UILabel!
    
    var timer: Timer?
    @IBOutlet var time: UILabel!
    @IBOutlet var seeker: UISlider!
    
    @IBOutlet var audioPlayerView: UIView!
    @IBOutlet var titleText: UITextView!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet var BtnCamera: UIButton!
    @IBOutlet weak var removeImageBtn: UIButton!
    
    var imageData = Data()
    var audioPath = ""
    
    var locationManager = CLLocationManager()
    
    var destination2d = CLLocationCoordinate2D()
    
    var category = ""
    var noteArray = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayerView.isHidden = true
        titleText.delegate = self
        titleText.text = "Enter Title"
        titleText.textColor = UIColor.lightGray
        removeImageBtn.isHidden = true
        selectedImage.isHidden = true
        descText.delegate = self
        descText.text = "Enter Description"
        descText.textColor = UIColor.lightGray
        
        locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
         
        locationManager.startUpdatingLocation()
        
        //audioplayer
        audioPlayerView.addShadow()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scrubAudio(_ sender: Any)
    {
        seeker.maximumValue = Float(audioPlayer.duration)
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(seeker.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @objc func updateSlider() {
    seeker.value = Float(audioPlayer.currentTime)
    }
    
    @objc func updateTime() {
        let currentTime = Int(audioPlayer.currentTime)
        let duration = Int(audioPlayer.duration)
        let total = currentTime - duration
        _ = String(total)

        let minutes = currentTime/60
        var seconds = currentTime - minutes / 60
        if minutes > 0 {
           seconds = seconds - 60 * minutes
            
        }
        
        time.text = NSString(format: "%02d:%02d", minutes,seconds) as String
    }
    func setDuration()
    {
        let duration = Int(audioPlayer.duration)
        let minutes = duration/60
        var seconds = duration - minutes / 60
        if minutes > 0 {
           seconds = seconds - 60 * minutes
        }
        durationLabel.text = NSString(format: "%02d:%02d", minutes,seconds) as String
        
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
              //grab user location
             
              
              let userLocation : CLLocation = locations[0]
              let lat = userLocation.coordinate.latitude
             let long = userLocation.coordinate.longitude
             
              let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
     
           destination2d = location
              

          }
      
    
    
    
    @IBAction func saveBtn(_ sender: Any)
    {
        let title = titleText.text
        let desc = descText.text
        let date = Date()
        let note = Note()
        note.lat = destination2d.latitude
        note.long = destination2d.longitude
        note.title = title!
        note.desc = desc!
        note.createdAt = date
        note.category = self.category
        if !(imageData.isEmpty)
        {
        note.imageData = self.imageData
        }
        if audioPlayerView.isHidden == false
        {
        note.audiopath = audioPath
        }
        print(imageData)
        noteArray.append(note)
        print(self.category)
        saveToCoreData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    func saveToCoreData()
    {
        //deleteData()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        for i in noteArray
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if descText.textColor == UIColor.lightGray {
            descText.text = ""
            descText.textColor = UIColor.black
        }
        if titleText.textColor == UIColor.lightGray {
            titleText.text = ""
            titleText.textColor = UIColor.black
        }
    }
    
   
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedImage.isHidden =  false
            self.selectedImage.image = image
            self.removeImageBtn.isHidden =  false
            //self.AddPhotoBTN.isHidden =  true
            imageData = image.pngData()!
        }
        self.dismiss(animated: true, completion: nil)
    }

   

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func removeImageBtn(_ sender: Any)
    {
        self.selectedImage.isHidden = true
        self.removeImageBtn.isHidden = true
        imageData = Data()
    }
    

    @IBAction func cameraBtn(_ sender: Any)
    {
        openDialog()
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func openDialog(){
               let alert = UIAlertController(title: "NoteIt!", message: "Pick image from", preferredStyle: .alert)

               

               alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in

                     if UIImagePickerController.isSourceTypeAvailable(.camera) {
                               var imagePicker = UIImagePickerController()
                               imagePicker.delegate = self
                               imagePicker.sourceType = .camera;
                               imagePicker.allowsEditing = false
                            self.present(imagePicker, animated: true, completion: nil)
                           }
               }))
               alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
                
                  
                         if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                             var imagePicker = UIImagePickerController()
                             imagePicker.delegate = self
                             imagePicker.sourceType = .photoLibrary;
                             imagePicker.allowsEditing = true
                             self.present(imagePicker, animated: true, completion: nil)
                         }
                     
               }))
               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               self.present(alert, animated: true)
           }
    
    
    @IBAction func recordBtn(_ sender: Any)
    {
        if(isRecording)
        {
            finishAudioRecording(success: true)
        //record_btn_ref.setTitle("Record", for: .normal)
            //play_btn_ref.isEnabled = true
            isRecording = false
            
            do{
                   
                       audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
                       var updateTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                       timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                       seeker.maximumValue = Float(audioPlayer.duration)
                       setDuration()
                       updateTime()
                   }
                   catch{
                           print(error)
                   }
            audioPlayerView.isHidden = false
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
    
    @IBAction func playBtn(_ sender: Any)
    {
        if(isPlaying)
        {
            audioPlayer.stop()
            updateTime()
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
                updateTime()
                isPlaying = true
            }
            else
            {
                display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
            }
        }
    }
    
    @IBAction func removeRecording(_ sender: Any)
    {
        audioPlayerView.isHidden = true
        
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
    
    func finishAudioRecording(success: Bool)
       {
           if success
           {
               audioRecorder.stop()
               audioRecorder = nil
               //meterTimer.invalidate()
               print("recorded successfully.")
            audioPath = getFileUrl().path
               
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
           let name = titleText.text + descText.text
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
