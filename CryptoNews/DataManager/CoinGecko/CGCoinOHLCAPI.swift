//
//  CGCoinOHLCAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/10/2021.
//

import Foundation


class CGAssetOHLCAPI:CoinGeckoAPI,ObservableObject{
    @Published var data:[CoinGeckoMainData.OHLCPointData] = []
    var asset:String
    var currency:String
    var days:Int
    
    init(asset:String,currency:String = "usd",days:Int = 1){
        self.asset = asset
        self.currency = currency
        self.days = days
    }
    
    static var shared:CGAssetOHLCAPI = .init(asset: "")
    
    var url:URL?{
        var url_comp = self.baseComponent
        url_comp.path = "/api/v3/coins/\(self.currency)/ohlc"
        
        url_comp.queryItems?.append(contentsOf: [
        
            URLQueryItem(name: "id", value: "\(self.asset)"),
            URLQueryItem(name: "vs_currency", value: "\(self.currency)"),
            URLQueryItem(name: "days", value: "\(self.days)")
        ])
        return url_comp.url
    }
    
    func getCoinOHLCData(completion:((Data) -> Void)? = nil){
        self.getInfo(_url: self.url, completion: completion ?? self.parseOHLCData(data:))
    }
    
    
    func parseOHLCData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode([[Float]].self, from: data)
            DispatchQueue.main.async {
                self.data = res.compactMap({CoinGeckoMainData.OHLCPointData(data: $0)})
            }
        }catch{
            print("Error while trying to parse data")
        }
    }
    
    static func parseCoinOHLCData(data:Data) -> [CoinGeckoMainData.OHLCPointData]{
        let decoder = JSONDecoder()
        var result:[CoinGeckoMainData.OHLCPointData] = []
        do{
            let res = try decoder.decode([[Float]].self, from: data)
            DispatchQueue.main.async {
                result = res.compactMap({CoinGeckoMainData.OHLCPointData(data: $0)})
            }
        }catch{
            print("Error while trying to parse data")
        }
        return result
    }
    
    
}
