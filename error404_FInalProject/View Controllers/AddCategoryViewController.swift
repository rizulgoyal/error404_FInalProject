//
//  AddCategoryViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-23.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    
    var categoryArray : [String] = []

    @IBAction func buttonCategory(_ sender: UIButton) {
        
        let newcategory = labelCategory.text
        categoryArray.append(newcategory!)
        let userDefaults = UserDefaults.standard

        userDefaults.removeObject(forKey: "category")
       userDefaults.set(categoryArray, forKey: "category")
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    @IBOutlet var labelCategory: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard

        
            categoryArray = userDefaults.stringArray(forKey: "category")!
            print(categoryArray[0])
            print("exists")
        

        // Do any additional setup after loading the view.
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
