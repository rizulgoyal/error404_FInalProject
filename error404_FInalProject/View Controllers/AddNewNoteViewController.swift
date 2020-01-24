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


class AddNewNoteViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate  {


    @IBOutlet var titleText: UITextField!
    
    @IBOutlet weak var descText: UITextView!
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    
    @IBOutlet weak var removeImageBtn: UIButton!
    
    var imageData = Data()
    
    var locationManager = CLLocationManager()
    
    var destination2d = CLLocationCoordinate2D()
    
    var category = ""
    var noteArray = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        removeImageBtn.isHidden = true
        selectedImage.isHidden = true
        descText.delegate = self
        descText.text = "Enter Description"
        descText.textColor = UIColor.lightGray
        
        locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
         
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
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
        noteArray.append(note)
        print(self.category)
        saveToCoreData()
        self.navigationController?.popViewController(animated: true)
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
    }
    
   
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedImage.isHidden =  false
            self.selectedImage.image = image
            self.removeImageBtn.isHidden =  false
            //self.AddPhotoBTN.isHidden =  true
            //imageData = image.pngData()!
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
    
    @IBAction func recordBtn(_ sender: Any)
    {
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
        
    

}
