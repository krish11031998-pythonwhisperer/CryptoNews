//
//  DataManagerHelper.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 11/11/2021.
//

import Foundation

public protocol Loopable{
    func allKeysValues(obj: Any?) throws -> [String:Any]
}

public extension Loopable{
    func allKeysValues(obj: Any?) throws -> [String:Any]{
        var result:[String:Any] = [:]
        var mirror = Mirror(reflecting: obj ?? self)
        
        guard let style = mirror.displayStyle, style == .class || style == .struct else{
            print("This isn't a struct or a class")
            throw NSError()
        }
        for (prop,value) in mirror.children{
            if let key = prop{
                if let val = value as? [String]{
                    result[key] = val
                }else if let val = value as? [Int]{
                    result[key] = val
                }else if let val = value as? [Any]{
                    result[key] = val.compactMap({ (el) -> Any? in
                        var res:[String:Any]? = nil
                        do {
                            res = try self.allKeysValues(obj: el)
                        }catch{
                            print(error)
                        }
                        return res
                    })
                }else{
                    result[key] = value
                }
                
            }
        }
        
        return result
    }
    
}
