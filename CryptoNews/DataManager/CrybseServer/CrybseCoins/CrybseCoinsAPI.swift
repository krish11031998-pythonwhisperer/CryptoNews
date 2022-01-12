//
//  CrybseCoinsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/01/2022.
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


class CrybseCoinsResponse:Codable{
    var data:[CrybseCoin]?
    var success:Bool
}

class CrybseCoinsAPI:CrybseAPI{
    @Published var coins:[CrybseCoin] = []
    
    var coinQuery:CrybseCoinQuery? = nil
    
    init(orderBy:String? = nil,orderDirection:String? = nil,tags:[String]? = nil,limit:Int? = nil,offset:Int? = nil){
        self.coinQuery = .init()
        self.coinQuery?.orderBy = orderBy
        self.coinQuery?.orderDirection = orderDirection
        self.coinQuery?.tags = tags
        self.coinQuery?.limit = limit
        self.coinQuery?.offset = offset
    }
    
    var queries:[URLQueryItem]?{
        guard let safeCoinQueries = self.coinQuery,let queriesMap = safeCoinQueries.keyValues else {return nil}
        var queries:[URLQueryItem]? = []
        for (key,value) in queriesMap{
            if let strVal = value as? String{
                queries?.append(.init(name: key, value: strVal))
            }else if let intVal = value as? Int{
                queries?.append(.init(name: key, value: "\(intVal)"))
            }else if let strValues = value as? [String]{
                for tag in strValues{
                    queries?.append(.init(name: "\(key)[]", value: tag))
                }
                
            }
            
        }
        return queries
    }
    
    var request:URLRequest?{
        return self.requestBuilder(path: "coins", queries: self.queries, headers: nil)
    }
    
    
    override func parseData(url: URL, data: Data) {
        let coins = self.parseCoinsFromData(data: data)
        if !coins.isEmpty{
            setWithAnimation {
                self.coins = coins
            }
        }
    }
    
    func parseCoinsFromData(data:Data) -> [CrybseCoin]{
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
    
    func getCoins(){
        guard let request = request else { return }
        self.getData(request: request)
    }
    
}
