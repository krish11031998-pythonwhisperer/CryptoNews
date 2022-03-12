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
    
    init(question:String = "Question",options:Array<String> = ["Yes","No"]){
        self.question = question
        self.options = options
    }
    
    var Question:String{
        return self.question ?? ""
    }
    
    var Options:Array<String>{
        return self.options ?? []
    }
}
