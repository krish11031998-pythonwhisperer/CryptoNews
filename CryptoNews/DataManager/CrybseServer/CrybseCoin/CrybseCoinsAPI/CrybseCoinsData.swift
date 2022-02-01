//
//  CrybseCoinsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/01/2022.
//

import Foundation

class CrybseCoinQuery:Loopable{
    var orderBy:String?
    var orderDirection:String?
    var tags:[String]?
    var limit:Int?
    var offset:Int?
    
    var keyValues:[String:Any]?{
        var res:[String:Any]? = nil
        do{
            res = try self.allKeysValues(obj: nil)
        }catch{
            print("(DEBUG) There was an error while trying to get teh keyValues : ",error.localizedDescription)
        }
        return res
    }
}

typealias CrybseCoins = [CrybseCoin]

extension CrybseCoins{
    static func parseCrybseCoinsFromData(data:Data) -> CrybseCoins{
        var res:[CrybseCoin] = []
        let decoder = JSONDecoder()
        do{
            let response = try decoder.decode(CrybseCoinsResponse.self, from: data)
            if let data = response.data, response.success{
                res = data
            }
        }catch{
            print("There was an issue with parsing the CoinResponse : ",error.localizedDescription)
        }
        return res
    }
}
