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
    var createdAt : Int64;
    var lat : Double;
    var long : Double;
    var category : String;
    var imageData: Data;
    var audiopath : String;
    
    init() {
      
        self.title = String()
        self.desc = String()
        self.category = String();
        self.audiopath = String()
        self.lat = Double();
        self.long = Double();
        self.createdAt = Int64();
        self.imageData = Data();
    }
}
