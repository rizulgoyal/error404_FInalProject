//
//  CategoryTableViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-22.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var count : Int?

    var categoryArray : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        let userDefaults = UserDefaults.standard
        if UserDefaults.exists(key: "category")
        {
            categoryArray = userDefaults.stringArray(forKey: "category")!
            print(categoryArray[0])
            print("exists")
        }
        else
        {
            categoryArray = ["Home","Work",""]
            userDefaults.set(categoryArray, forKey: "category")
            userDefaults.synchronize()
            print("dont exist")
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        
            categoryArray = userDefaults.stringArray(forKey: "category")!
       
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryLabel", for: indexPath) as! CategoryTableViewCell
        
        cell.categoryName.text = categoryArray[indexPath.row]
        
        let number = loadFromCoreData(category: categoryArray[indexPath.row])
        cell.countlabel.text = String(number)
        cell.contentView.addShadow1()
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 6
        return cell
    }
    

    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let newVC = sb.instantiateViewController(identifier: "notesTable") as! NotesTableViewController
        newVC.category = categoryArray[indexPath.row]
        navigationController?.pushViewController(newVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func loadFromCoreData(category : String) -> Int
         {
           
          // self.clearCoreData()
           

             let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   
                    let context = appDelegate.persistentContainer.viewContext
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
             fetchRequest.returnsObjectsAsFaults = false

              
              let predicate = NSPredicate(format: "category=%@", "\(category)")
              fetchRequest.predicate = predicate
              if let result = try? context.fetch(fetchRequest) {
                count = result.count
//               for object in result as! [NSManagedObject] {
//
//                   let title = object.value(forKey: "title")
//                   let desc = object.value(forKey: "desc")
//                   let lat = object.value(forKey: "latitude")
//                   let long = object.value(forKey: "longitude")
//
//
//                   let note = Note()
//                   note.title = title as! String
//                   note.desc = desc as! String
//                   note.lat = lat as! Double
//                   note.long = long as! Double
//
//
//                   notesArray.append(note)
                  }
            return count!
              }
           
           
       
//       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//           if let newVC = segue.destination as? AddNewNoteViewController
//           {
//           newVC.category = self.category
//           }
//       }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    

   
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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

extension UserDefaults {

    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

}
extension UIView {

    func addShadow1(){
       self.layer.cornerRadius = 30.0
       self.layer.shadowColor = UIColor.gray.cgColor
        //self.layer.borderColor = UIColor.black.cgColor
       self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
       self.layer.shadowRadius = 15.0
       self.layer.shadowOpacity = 0.7

    }
}

