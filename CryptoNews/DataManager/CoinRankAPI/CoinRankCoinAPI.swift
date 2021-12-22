//
//  CoinRankCoinAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/12/2021.
//

import Foundation

class CoinRankCoinAPI:CoinRankAPI{
    
    @Published var coin:CoinData? = nil
    var queryItems:[URLQueryItem] = []
    var coin_uuid:String = ""
    
    init(coin:String,timePeriod:String){
        super.init()
        self.coin_uuid = coin
        self.parseQueryItems(queryItems: &queryItems,key: "timePeriod", query: timePeriod)
    }
    
    var coinPath:String{
        return "\(CoinRankAPIEndpoint.coin.rawValue)/\(coin_uuid)"
    }
    
    var request:URLRequest?{
        return self.requestBuilder(path: self.coinPath, queries: self.queryItems)
    }
    
    override func parseData(url: URL, data: Data) {
        print("(DEBUG) Got CoinRank Data !")
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CoinsData.self, from: data)
            print("(DEBUG) Parsed CoinRank Data !")
            DispatchQueue.main.async {
                self.coin = res.data?.coin
                if self.loading{
                    self.loading.toggle()
                }
            }
        }catch{
            print("(DEBUG) There was an error while decoding the CoinsData : ",error.localizedDescription)
        }
    }
    
    func getCoin(){
        guard let request = self.request else {return}
        self.getData(request: request)
    }
    
    func refreshCoin(){
        guard let request = self.request else {return}
        self.refreshData(request: request)
    }
    
}
