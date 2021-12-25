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
        
        self.parseQueryItems(queryItems: &queryItems,key: "timePeriod", query: timePeriod)
        self.parseQueryItems(queryItems: &queryItems,key: "symbols", query: symbols as Any)
        self.parseQueryItems(queryItems: &queryItems,key: "uuids", query: uuids as Any)
        self.parseQueryItems(queryItems: &queryItems,key: "tags", query: tags as Any)
        self.parseQueryItems(queryItems: &queryItems,key: "limit", query: limit as Any)
    }
    
    var request:URLRequest?{
        guard let request = self.requestBuilder(path: CoinRankAPIEndpoint.coins.rawValue, queries: self.queryItems,headers: self.requestHeaders) else {return nil}
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
