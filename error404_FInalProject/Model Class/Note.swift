//
//  Note.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-22.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import Foundation

class Note
{
    var title : String;
    var desc : String;
    var createdAt : Date = Date()
    var lat : Double;
    var long : Double;
    var category : String;
    var imageData: Data;
    var audiopath : String;
    var dateString : String
    
    init() {
      
        self.title = String()
        self.desc = String()
        self.category = String();
        self.audiopath = String()
        self.lat = Double();
        self.long = Double();
        self.createdAt = Date();
        self.imageData = Data();
        let formatter = DateFormatter()
               formatter.dateFormat = "dd/MM/yyyy hh:mm a"
               self.dateString = formatter.string(from: createdAt)
               
    }
    
    
}

extension Date
{
    
    func dateformatter() -> String {
        let dateFormatterPrint=DateFormatter()
        dateFormatterPrint.dateFormat="dd/MM/yyyy"
        let formattedDate = dateFormatterPrint.string(from: self)
        return formattedDate
        
    }
}
