//
//  CrybsePollData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/02/2022.
//

import Foundation

struct CrybsePollData:Codable{
    var question:String?
    var options:Array<String>?
    
    
    var Question:String{
        return self.question ?? ""
    }
    
    var Options:Array<String>{
        return self.options ?? []
    }
}
