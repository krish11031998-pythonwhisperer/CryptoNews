//
//  FloatHelper.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/11/2021.
//

import Foundation


func convertToDecimals(value:Float?) -> String{
    guard let value = value else {return "$0"}
    let decimal = value.truncatingRemainder(dividingBy: 1) != 0 ? "%.2f" : "%.0f"
    if value > 1000 && value < 1000000{
        return "\(String(format: decimal, value/1000))k"
    }else if value > 1000000 && value < 1000000000{
        return "\(String(format: decimal,value/1000000))M"
    }else if value > 1000000000{
        return "\(String(format: decimal,value/1000000000))B"
    }else{
        return "\(String(format: decimal,value))"
    }
}

func convertToMoneyNumber(value:Float?) -> String{
    guard let _value = value else {return "$0"}
    let value = abs(_value)
    var result:String = ""
    let decimal = value.truncatingRemainder(dividingBy: 1) != 0 ? "%.2f" : "%.0f"
    if value > 1000 && value < 1000000{
        result = "$\(String(format: decimal, value/1000))k"
    }else if value > 1000000 && value < 1000000000{
        result =  "$\(String(format: decimal,value/1000000))M"
    }else if value > 1000000000 && value < 999999995904{
        result =  "$\(String(format: decimal,value/1000000000))B"
    }else if value >= 999999995904{
        result =  "$\(String(format: decimal,value/1000000000000))T"
    }else{
        result =  "$\(String(format: decimal,value))"
    }
    
    return _value < 0 ? "- "+result : result
}


public extension Float{
    
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
