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
            categoryArray = ["Home","Work"]
            userDefaults.set(categoryArray, forKey: "category")
            userDefaults.synchronize()
            print("dont exist")
        }
        
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
        cell.contentView.addShadow()
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 6
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(
            style: .normal,
            title: "Delete",
            handler: { (action, view, completion) in
                
                
                let alert = UIAlertController(title: "Delete Folder", message: "All the Notes will be Deleted as Well,Are You Sure You Want to Delete the folder ?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Delete", style: .destructive){
                    UIAlertAction in
                    self.categoryArray.remove(at: indexPath.row)
                    let userDefaults = UserDefaults.standard
                    userDefaults.removeObject(forKey: "category")
                    userDefaults.set(self.categoryArray, forKey: "category")
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                }
                alert.addAction(okAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
                
                
                
        })
        
        
        action.backgroundColor = .red
        action.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions:  [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let newVC = sb.instantiateViewController(identifier: "notesTable") as! NotesTableViewController
        newVC.category = categoryArray[indexPath.row]
        navigationController?.pushViewController(newVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @IBAction func addFolderBtn(_ sender: Any)
    {
        let alert = UIAlertController(title: "Add New Folder", message: "Type the name of new folder", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Add Folder", style: .default){
            UIAlertAction in
            let newcategory = alert.textFields![0].text
            
            
            if self.categoryArray.contains(newcategory!)
            {
                
                let alert = UIAlertController(title: "Cannot Add ", message: "Folder already exists.", preferredStyle: .alert)
                alert.addAction(UIKit.UIAlertAction(title: "OK", style: .cancel, handler: nil))
                //alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                self.categoryArray.append(newcategory!)
            let userDefaults = UserDefaults.standard
            
            userDefaults.removeObject(forKey: "category")
            userDefaults.set(self.categoryArray, forKey: "category")
            self.categoryArray.removeAll()
            self.categoryArray = userDefaults.array(forKey: "category") as! [String]
            self.tableView.reloadData()
            }
            
        }
        alert.addAction(okAction)
        okAction.isEnabled = false
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Folder Name"
            textField.textAlignment = .center
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    // If the text contains non whitespace characters, enable the OK Button
                    okAction.isEnabled = textIsNotEmpty
            })
        })
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func okButtonTapped()
    {
        
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
        if let result = try? context.fetch(fetchRequest)
        {
            count = result.count
        }
        return count!
    }
    
    
    
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
}

//extension to find category array
extension UserDefaults {
    
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}

//extension to add shadow to cell
extension UIView {
    
    func addShadow1(){
        self.layer.cornerRadius = 20.0
        self.layer.shadowColor = UIColor.gray.cgColor
        //self.layer.borderColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 10.0
        self.layer.shadowOpacity = 0.7
        
    }
}

