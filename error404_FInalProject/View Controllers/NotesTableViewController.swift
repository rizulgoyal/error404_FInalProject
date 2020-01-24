//
//  NotesTableViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-22.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class NotesTableViewController: UITableViewController,  CLLocationManagerDelegate{

    var category = ""
    var notesArray = [Note]()
    var addressm = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        clearCoreData()
//        notesArray.removeAll()
        loadFromCoreData()
    
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        notesArray.removeAll()
        loadFromCoreData()
        print(notesArray.count)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notesArray.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesTableViewCell
       let currnote =  notesArray[indexPath.row]
        cell.titleLabel.text = currnote.title
        
        
        // new code
        let location = CLLocation(latitude: currnote.lat, longitude: currnote.long)
        var address = ""

         CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) in
                    if let error = error
                    {
                        print(error)
                    }
                    else
                    {
                        if let placemark = placemarks?[0]{
        //                    if placemark.subThoroughfare != nil{
        //                        address = address + placemark.subThoroughfare! + " "
        //                    }
        //
        //                    if placemark.thoroughfare != nil{
        //                        address = address + placemark.thoroughfare! + " "
        //                    }
        //
        //                    if placemark.subLocality != nil{
        //                        address = address + placemark.subLocality!  + " "
        //                    }
        //
                            if placemark.subAdministrativeArea != nil{
                             //   annotation.title = placemark.subAdministrativeArea

                                address = address + placemark.subAdministrativeArea! + " "
                            }
                            
        //                    if placemark.postalCode != nil{
        //                        address = address + placemark.postalCode! + " "
        //                    }
                            
                            if placemark.country != nil{
                                address = address + placemark.country! + " "
                            }
                          
                            self.addressm = address
                            cell.addressLabel.text = address
       
                      }
                        
                    }
                        
                    }
    
        cell.addressLabel.text = addressm
        
        cell.dateLabel.text = currnote.dateString
        
        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let newVC = sb.instantiateViewController(identifier: "noteDetail") as! DetailTaskViewController
        let currnote =  notesArray[indexPath.row]

        newVC.note = currnote
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func loadFromCoreData()
      {
        
       // self.clearCoreData()
        

          let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                 let context = appDelegate.persistentContainer.viewContext
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
          fetchRequest.returnsObjectsAsFaults = false

           
           let predicate = NSPredicate(format: "category=%@", "\(category)")
           fetchRequest.predicate = predicate
           if let result = try? context.fetch(fetchRequest) {
            for object in result as! [NSManagedObject] {
                
                let title = object.value(forKey: "title")
                let desc = object.value(forKey: "desc")
                let lat = object.value(forKey: "latitude")
                let long = object.value(forKey: "longitude")

                
                let note = Note()
                note.title = title as! String
                note.desc = desc as! String
                note.lat = lat as! Double
                note.long = long as! Double
                
                
                notesArray.append(note)
               }
           }
        
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? AddNewNoteViewController
        {
        newVC.category = self.category
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
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
