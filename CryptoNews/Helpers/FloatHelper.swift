//
//  FloatHelper.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import Foundation

extension Float{
    
    func toString() -> String{
        let num = self
        return "\(num)"
    }
    
    func ToMoney() -> String{
        let num = self
        return convertToMoneyNumber(value: num)
    }
    
    
    func ToDecimals() -> String{
        return convertToDecimals(value: self)
    }
    
}
