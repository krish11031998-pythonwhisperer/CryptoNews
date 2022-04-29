//
//  JSONUtils.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/04/2022.
//

import Foundation

func readJsonFile(forName name:String) -> Data?{
    do{
        if let bundlePath = Bundle.main.url(forResource: name, withExtension: "json"){
            let jsonData = try String(contentsOf: bundlePath).data(using: .utf8)
            return jsonData
        }
    }catch{
        print("There was an error : ",error.localizedDescription)
    }
    return nil
}
