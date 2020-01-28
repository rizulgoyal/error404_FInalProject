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
import MediaPlayer
import Photos

class DetailTaskViewController: UIViewController, UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //pre required data from notesTableviewCOntroller
    var note = Note()
    var notesArray : [Note] = []
    var categoryPassed = ""
    var imageData = Data()
    var count = Int()
    
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
    @IBOutlet var seeker: UISlider!
    @IBOutlet var time: UILabel!
    @IBOutlet var durationLabel: UILabel!
    var timer : Timer?
    
    //outlets
    @IBOutlet var removeImgBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var textTitle: UITextView!
    @IBOutlet var cameraBtn: UIButton!
    @IBOutlet var imageTask: UIImageView!
    @IBOutlet var labelDesc: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //back functionality
        count = 0
        
        //textView Customization
        textTitle.delegate = self
        textTitle.textContainer.maximumNumberOfLines = 1
        
        //displaying data
        textTitle.text = note.title
        labelDesc.text = note.desc
        let imgData = note.imageData
        imageTask.isHidden = true
        removeImgBtn.isHidden = true
        if !(imgData.isEmpty)
        {
            imageTask.isHidden = false
            removeImgBtn.isHidden = false
            
            let img = UIImage(data: imgData)
            imageTask.image = img
        }
        
        
        
        
        //code for audio player
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
        audioPlayerView.addShadow1()
        
        //code after adding audio
        if note.audiopath.elementsEqual("")
        {
            audioPlayerView.isHidden = true
        }
        else
        {
            audioPlayerView.isHidden = false
        }
        
        
        //setting large titles
        navigationController?.navigationItem.largeTitleDisplayMode = .never
       
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print(categoryPassed)
        if count == 0{
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
            if imageTask.isHidden
            {
                note1.imageData.removeAll()
            }else{
                note1.imageData = note.imageData
            }
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
            if audioPlayerView.isHidden
            {
                note1.audiopath = ""
            }else
            {
                note1.audiopath = note.audiopath
            }
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
        
    }
    
    
    //segue task
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? mapLocationViewController{
            newVC.lat = note.lat
            newVC.long = note.long
        }
    }
    
    //textView Customization
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        //self.resignFirstResponder()//        labelDesc.becomeFirstResponder()
        
        return linesAfterChange == textView.textContainer.maximumNumberOfLines
        
        
    }
    
    //save btn fucntionality
    @IBAction func saveBtn(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    //delete note btn
    @IBAction func deleteBtn(_ sender: Any)
    {
        let alert = UIAlertController(title: "Delete Note", message: "Are You Sure You Want to Delete the Note?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive){
            UIAlertAction in
            self.deleteData()
            self.count = 1
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    

    
    //image part
    
    @IBAction func removeImageBtn(_ sender: Any)
    {
        
        let alert = UIAlertController(title: "Delete Image", message: "Are You Sure You Want to Delete the Image form the Note?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive){
            UIAlertAction in
            self.imageTask.isHidden = true
            self.removeImgBtn.isHidden = true
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func cameraBtn(_ sender: Any)
    {
        if imageTask.isHidden
        {
        openDialog()
        }
        else
        {
            let alert = UIAlertController(title: "Replace Image", message: "are you sure you want to replace the image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                self.openDialog()
            }))
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func openDialog(){
        
        let alert = UIAlertController(title: "Select Image", message: "Pick image from", preferredStyle: .actionSheet)
        
        
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageTask.isHidden =  false
            self.imageTask.image = image
            self.removeImgBtn.isHidden = false
            //self.AddPhotoBTN.isHidden =  true
            note.imageData = image.pngData()!
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func startRecording(_ sender: Any)
    {
        
        if audioPlayerView.isHidden
        {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.performRecord()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        }
        else
        {
            let alert = UIAlertController(title: "Replace Audio", message: "Are you sure you want to replace the audio", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                let recordingSession = AVAudioSession.sharedInstance()
                       
                       do {
                           try recordingSession.setCategory(.playAndRecord, mode: .default)
                           try recordingSession.setActive(true)
                           recordingSession.requestRecordPermission() { [unowned self] allowed in
                               DispatchQueue.main.async {
                                   if allowed {
                                       self.performRecord()
                                   } else {
                                       // failed to record!
                                   }
                               }
                           }
                       } catch {
                           // failed to record!
                       }
               
            }))
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func performRecord()
    {
        if(isRecording == false)
        {
            check_record_permission()
            setup_recorder()
            
            audioRecorder.record()
            
            
            //meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //record_btn_ref.setTitle("Stop", for: .normal)
            //play_btn_ref.isEnabled = false
            isRecording = true
            display_alert1(msg_title: "Recording Audio Note", msg_desc: "app is now recording audio", action_title: "stop")
            
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
    
    @IBAction func removeRecording(_ sender: Any)
    {
        
        let alert = UIAlertController(title: "Delete Recording", message: "Are You Sure You Want to Delete the Audio Note?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive){
            UIAlertAction in
            self.audioPlayerView.isHidden = true
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func scrubAudio(_ sender: Any) {
        seeker.maximumValue = Float(audioPlayer.duration)
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(seeker.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
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
    
    //custom display alerts
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
    func display_alert1(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .destructive)
        {
            (result : UIAlertAction) -> Void in
            if(self.isRecording)
            {
                self.finishAudioRecording(success: true)
                //record_btn_ref.setTitle("Record", for: .normal)
                //play_btn_ref.isEnabled = true
                self.isRecording = false
                do{
                    
                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.getFileUrl())
                    var updateTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                    self.timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
                    self.seeker.maximumValue = Float(self.audioPlayer.duration)
                    self.setDuration()
                    self.updateTime()
                }
                catch{
                    print(error)
                }
                self.audioPlayerView.isHidden = false
                self.note.audiopath = "\(self.getFileUrl())"
                //print(note.audiopath)
                
            }
    
        })
        present(ac, animated: true)
    }
    
}
