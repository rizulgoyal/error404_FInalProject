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


class AddNewNoteViewController: UIViewController, CLLocationManagerDelegate {


    @IBOutlet var titleText: UITextField!
    
    @IBOutlet weak var descText: UITextView!
    
    
    
    
    var locationManager = CLLocationManager()
    
    var destination2d = CLLocationCoordinate2D()
    
    var category = ""
    var noteArray = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
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
              //define delta (difference) of lat and long
          //    let latDelta : CLLocationDegrees = 0.09
       //      let longDelta : CLLocationDegrees = 0.09

      //        //define span
           //   let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
      //
      //
      //        //define location
              let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
      //
      //        //define region
             // let region = MKCoordinateRegion(center: location, span: span)
      //
      //        // set the region on the map
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
        noteArray.append(note)
        print(self.category)
        saveToCoreData()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
