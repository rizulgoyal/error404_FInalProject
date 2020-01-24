//
//  DetailTaskViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-23.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit

class DetailTaskViewController: UIViewController {

    
    var note = Note()
    
    @IBOutlet var labelTitle: UITextField!
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet var imageTask: UIImageView!
    @IBOutlet var labelDesc: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = note.title
        labelDesc.text = note.desc
        let imgData = note.imageData
        imageTask.isHidden = true
        imageLabel.isHidden  = true
        if !(imgData.isEmpty)
        {
            imageTask.isHidden = false
            imageLabel.isHidden  = false
            
            let img = UIImage(data: imgData)
            imageTask.image = img
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newVC = segue.destination as? mapLocationViewController{
            newVC.lat = note.lat
            newVC.long = note.long
        }
    }
    


}
