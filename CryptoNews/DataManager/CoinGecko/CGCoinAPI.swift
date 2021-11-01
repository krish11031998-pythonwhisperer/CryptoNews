//
//  CGCoinAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/10/2021.
//

import SwiftUI

class CGCoinAPI:CoinGeckoAPI,ObservableObject{
    @Published var data:CoinGeckoAsset? = nil
    var currency:String
    var localization:Bool
    var tickers:Bool
    var market_data:Bool
    var community_data:Bool
    var developer_data:Bool
    var sparkline:Bool
    init(currency:String,
         localization:Bool = false,
         ticker:Bool = false,
         market_data:Bool = true,
         community_data:Bool = false,
         developer_data:Bool = false,
         sparkline:Bool = true
    ){
        self.currency = currency
        self.localization = localization
        self.tickers = ticker
        self.market_data = market_data
        self.community_data = community_data
        self.developer_data = developer_data
        self.sparkline = sparkline
    }
    
    static var shared:CGCoinAPI = .init(currency: "")
    
    var url:URL?{
        var url_comp = self.baseComponent
        url_comp.path = "/api/v3/coins/\(self.currency)"
        
        var queryItems = [
            URLQueryItem(name: "localization", value: "\(self.localization)"),
            URLQueryItem(name: "tickers", value: "\(self.tickers)"),
            URLQueryItem(name: "market_data", value: "\(self.market_data)"),
            URLQueryItem(name: "community_data", value: "\(self.community_data)"),
            URLQueryItem(name: "developer_data", value: "\(self.developer_data)"),
            URLQueryItem(name: "sparkline", value: "\(self.sparkline)")
        ]
        print("queryItems : ",queryItems)
        url_comp.queryItems = queryItems
        print(url_comp.queryItems)
        print("(DEBUG) : ", url_comp)
        return url_comp.url
    }
    
    func getCoinData(completion:((Data) -> Void)? = nil){
        
        self.getInfo(_url: self.url, completion: completion ?? self.parseData(data:))
    }
    
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CoinGeckoAsset.self, from: data)
            DispatchQueue.main.async {
                self.data = res
            }
        }catch{
            print("Error while trying to parse data")
        }
    }
    
    
    static func parseCoinData(data:Data) -> CoinGeckoAsset?{
        let decoder = JSONDecoder()
        var result:CoinGeckoAsset? = nil
        do{
            result = try decoder.decode(CoinGeckoAsset.self, from: data)
            
        }catch{
            print("Error while trying to parse data")
        }
        return result
    }
    
    
    
    
}
