//
//  Array.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import Foundation


public extension Array{
    var secondLast:ArrayLiteralElement?{
        let count = self.count
        if count > 0 {
            return self[count - 1]
        }else{
            return nil
        }
    }
    
    func limitData(limit:Int) -> Array<ArrayLiteralElement>{
        return self.count > limit ? Array(self[0..<limit]) : self
    }
}
