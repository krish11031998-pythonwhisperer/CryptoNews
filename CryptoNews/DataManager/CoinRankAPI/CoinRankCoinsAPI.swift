//
//  CoinRankCoinsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import Foundation


class CoinRankCoinsAPI:CoinRankAPI{
    
    @Published var coins:CoinsData? = nil
    var queryItems:[URLQueryItem] = []
    
    init(timePeriod:String = "24h",symbols:[String]? = nil,uuids:[String]? = nil,tags:[String]? = nil,limit:Int? = nil){
        super.init()
        self.parseQueryItems(key: "timePeriod", query: timePeriod)
        self.parseQueryItems(key: "symbols", query: symbols as Any)
        self.parseQueryItems(key: "uuids", query: uuids as Any)
        self.parseQueryItems(key: "tags", query: tags as Any)
        self.parseQueryItems(key: "limit", query: limit as Any)
    }
    
    
    func parseQueryItems(key:String,query:Any){
        var finalQuery:[URLQueryItem] = []
        if let value = query as? String{
            finalQuery.append(.init(name: key, value: value))
        }else if let values = query as? [String]{
            finalQuery = values.compactMap({.init(name: "\(key)=", value: $0)})
        }else if let value = query as? Int{
            finalQuery.append(.init(name: key, value: "\(value)"))
        }else{
            return
        }
        
//        self.queryItems.append(contentsOf: finalQuery)

        self.queryItems.append(contentsOf: finalQuery)

    }
    
    var request:URLRequest?{
        guard let request = self.requestBuilder(path: CoinRankAPIEndpoint.coins.rawValue, queries: self.queryItems) else {return nil}
        return request
    }
    
    
    override func parseData(url: URL, data: Data) {
        print("(DEBUG) Got CoinRank Data !")
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CoinsData.self, from: data)
            print("(DEBUG) Parsed CoinRank Data !")
            DispatchQueue.main.async {
                self.coins = res
                if self.loading{
                    self.loading.toggle()
                }
            }
        }catch{
            print("(DEBUG) There was an error while decoding the CoinsData : ",error.localizedDescription)
        }
    }
    
    func getCoinsData(){
        guard let request = request else {return}
//        self.getData(request: request)
        self.getData(request: request)
    }
    
    
}
