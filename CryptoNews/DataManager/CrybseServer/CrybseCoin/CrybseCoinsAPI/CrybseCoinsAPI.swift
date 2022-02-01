//
//  CrybseCoinsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/01/2022.
//

import Foundation

class CrybseCoinsResponse:Codable{
    var data:CrybseCoins?
    var success:Bool
}

class CrybseCoinsAPI:CrybseAPI{
    @Published var coins:CrybseCoins = []
    
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
        let coins = CrybseCoins.parseCrybseCoinsFromData(data: data)
        if !coins.isEmpty{
            setWithAnimation {
                self.coins = coins
            }
        }
    }
    
    func getCoins(){
        guard let request = request else { return }
        self.getData(request: request)
    }
    
}
