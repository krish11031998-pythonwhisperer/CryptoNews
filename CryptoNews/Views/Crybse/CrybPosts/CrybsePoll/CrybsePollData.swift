//
//  CrybsePollData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/02/2022.
//

import Foundation

class CrybsePollData:Codable,ObservableObject{
    @Published var question:String?
    @Published var options:Array<String>?
    @Published var optionsCount:[String:Int]?
    
    
    enum CodingKeys:CodingKey{
        case question
        case options
        case optionsCount
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decodeIfPresent(String.self, forKey: .question)
        self.options = try container.decodeIfPresent(Array<String>.self, forKey: .options)
        self.optionsCount = try container.decodeIfPresent(Dictionary<String,Int>.self, forKey: .optionsCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(question, forKey: .question)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(optionsCount, forKey: .optionsCount)
    }
    
    
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
    
    var TotalVoteCount:Int{
        return self.optionsCount?.values.reduce(0, {$0 + $1}) ?? 0
    }
    
    func OptionRatio(option:String) -> Float{
        if self.TotalVoteCount > 0 {
            return Float(self.CountForOptions(option: option))/Float(self.TotalVoteCount)
        }else{
            return 0
        }
        
    }
    
    func CountForOptions(option:String) -> Int{
        if let count = self.optionsCount?[option]{
            return count
        }
        return 0
    }

    func UpdateOptionCount(option:String,count:Int = 1){
        if self.optionsCount == nil{
            self.optionsCount = [:]
        }
        if let presentCount = self.optionsCount?[option]{
            self.optionsCount?[option] = presentCount + count
        }else{
            self.optionsCount?[option] = count
        }
    }
    
    
}
