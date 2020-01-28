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

class NotesTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate{
    
    @IBOutlet var sortBtn: UIButton!
    
    //search
    let searchController = UISearchController(searchResultsController: nil)
    
    
    var category = ""
    var notesArray = [Note]()
    var searchArray = [Note]()
    var isSearch = false
    
    var addressm = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        
        loadFromCoreData()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
    
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
        if isSearch
        {
            return searchArray.count
        }
        else
        {
            return notesArray.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesTableViewCell
        
        if isSearch
        {
            let currnote =  searchArray[indexPath.row]
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
                        
                        if placemark.subAdministrativeArea != nil{
                            
                            address = address + placemark.subAdministrativeArea! + " "
                        }
                        
                        if placemark.country != nil{
                            address = address + placemark.country! + " "
                        }
                        
                        self.addressm = address
                        cell.addressLabel.text = address
                        
                    }
                    
                }
                
            }
            
            cell.addressLabel.text = addressm
            cell.descLabel.text = currnote.desc
            cell.dateLabel.text = currnote.dateString
            
        }
        else
        {
            
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
                        
                        if placemark.subAdministrativeArea != nil{
                            
                            address = address + placemark.subAdministrativeArea! + " "
                        }
                        
                        if placemark.country != nil{
                            address = address + placemark.country! + " "
                        }
                        
                        self.addressm = address
                        cell.addressLabel.text = address
                        
                    }
                    
                }
                
            }
            
            cell.addressLabel.text = addressm
            cell.descLabel.text = currnote.desc
            cell.dateLabel.text = currnote.dateString
            
            
        }
        cell.contentView.addShadow()
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 6
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let newVC = sb.instantiateViewController(identifier: "noteDetail") as! DetailTaskViewController
        var currnote = Note()
        if isSearch
        {
            currnote =  searchArray[indexPath.row]
        }
        else{
            currnote = notesArray[indexPath.row]
        }
        
        newVC.note = currnote
        newVC.categoryPassed = self.category
        print(currnote.category)
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // first action for adding day
        let action = UIContextualAction(
            style: .normal,
            title: "Change Folder",
            handler: { (action, view, completion) in
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let newVC = sb.instantiateViewController(identifier: "chooseCategroy") as! ChooseCategoryTableViewController
                newVC.note = self.notesArray[indexPath.row]
                print(self.notesArray[indexPath.row].title)
                self.navigationController?.pushViewController(newVC, animated: true)
                
                
                
                
                //
                //                                  completion(true)
        })
        
        
        action.backgroundColor = .lightGray
        action.image = UIImage(systemName: "folder")
        
        
        
        // second action for delete
        
        let action1 = UIContextualAction(
            style: .normal,
            title: "Delete Note",
            handler: { (action, view, completion) in
                
                let   appdelegate = UIApplication.shared.delegate as! AppDelegate;
                
                let context = appdelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
                fetchRequest.returnsObjectsAsFaults = false
                
                
                let predicate = NSPredicate(format: "category=%@", "\(self.category)")
                fetchRequest.predicate = predicate
                
                do
                {
                    let x = try context.fetch(fetchRequest)
                    let result = x as! [Notes]
                    print(result.count)
                    
                    print("deleting \(result[indexPath.row])")
                    context.delete(result[indexPath.row])
                    //print(zotes)
                    print(indexPath.row )
                    do
                    {
                        try context.save()
                    }
                    catch{
                        
                        print("error")
                    }
                    self.notesArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                    
                }
                catch
                {
                    
                }
                
                completion(true)
        })
        
        
        action1.backgroundColor = .red
        action1.image = UIImage(systemName: "trash")
        
        
        let configuration = UISwipeActionsConfiguration(actions: [action1, action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    @IBAction func sortBy(_ sender: Any)
    {
        let alert = UIAlertController(title: "Sort Table", message: "Please Select one option", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "By Title", style: .default, handler: {
            action in
            
            self.notesArray.sort(by:  {$0.title.lowercased() < $1.title.lowercased()} )
            self.sortBtn.setTitle("Sort By Title", for: .normal)
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "By Date", style: .default, handler: {
            action in
            
            
            self.notesArray.sort(by: {$0.createdAt < $1.createdAt} )
            self.sortBtn.setTitle("Sort By Date", for: .normal)
            self.tableView.reloadData()
            
        }))
        
        self.present(alert, animated: true)
    }
    
    func searchResult(searchText : String)
    {
        let filtered = notesArray.filter { $0.title.lowercased().contains(searchText.lowercased()) || $0.desc.lowercased().contains(searchText.lowercased())}
        
        if filtered.count>0
        {
            //tasks = []
            searchArray = filtered;
            isSearch = true;
        }
        else
        {
            searchArray = self.notesArray
            isSearch = false;
        }
        self.tableView.reloadData();
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        let filtered = notesArray.filter { $0.title.lowercased().contains(searchText.lowercased()) || $0.desc.lowercased().contains(searchText.lowercased())}
        
        if filtered.count>0
        {
            //tasks = []
            searchArray = filtered;
            isSearch = true;
        }
        else
        {
            searchArray = self.notesArray
            isSearch = false;
        }
        self.tableView.reloadData();
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true;
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
    
    
    
    
    func loadFromCoreData()
    {
        
        // self.clearCoreData()
        
        
        // new
        
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
                let image = object.value(forKey: "image")
                let category = object.value(forKey: "category")
                let audiopath = object.value(forKey: "audiopath")
                
                
                let note = Note()
                note.title = title as! String
                note.desc = desc as! String
                note.lat = lat as! Double
                note.long = long as! Double
                note.category = category as! String
                if (image != nil)
                {
                    note.imageData  = image as! Data
                }
                if (audiopath != nil)
                {
                    note.audiopath = audiopath as! String
                }
                
                
                notesArray.append(note)
            }
        }
        
    }
    
    
}
extension UIView {
    
    func setCardView(){
        layer.cornerRadius = 5.0
        layer.borderColor  =  UIColor.clear.cgColor
        layer.borderWidth = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowColor =  UIColor.lightGray.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width:5, height: 5)
        layer.masksToBounds = true
    }
    func addShadow(){
        self.layer.cornerRadius = 30.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 12.0
        self.layer.shadowOpacity = 0.7
        
    }
}
extension NotesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchResult(searchText: searchBar.text!)
    }
}
