//
//  ChooseCategoryTableViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-26.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import CoreData

class ChooseCategoryTableViewController: UITableViewController {

    var count : Int?
    var note : Note?
    var categoryArray : [String] = []
    var notesArray : [Note] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard
        categoryArray = userDefaults.stringArray(forKey: "category")!
        loadFromCoreData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCell", for: indexPath)  as! ChooseCategoryTableViewCell
        cell.contentView.addShadow()
        
        cell.chooseCategory.text = categoryArray[indexPath.row]
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCategory = categoryArray[indexPath.row]
        note?.category = newCategory
        let title = note?.title
        let desc = note?.desc
        let date = note!.createdAt
        let image = note!.imageData
        let category = note!.category
        let lat = note!.lat
        let long = note!.long
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
                    let originPath = path.appendingPathComponent(note!.title+note!.desc)
                       print(originPath)
                       let destinationPath = path.appendingPathComponent(title!+desc!)
                       print(destinationPath)
                           try FileManager.default.moveItem(at: originPath, to: destinationPath)
                       } catch {
                           print(error)
                       }
                   
               }
        note1.audiopath = note!.audiopath
        
               print(note1.audiopath)
               note1.category = newCategory
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
        navigationController?.popViewController(animated: true)
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl() -> URL
    {
        let name = note!.title + note!.desc
        let filename = name
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        print(filePath)
    return filePath
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

               
        let predicate = NSPredicate(format: "title=%@", "\(note!.title)")
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
