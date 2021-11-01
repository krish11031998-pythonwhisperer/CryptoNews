//
//  CGMarketAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 01/11/2021.
//

import Foundation

enum CGMarketOrder:String{
    case market_cap_desc = "market_cap_desc"
    case gecko_desc = "gecko_desc"
    case gecko_asc = "gecko_asc"
    case market_cap_asc = "market_cap_asc"
    case volume_asc = "volume_asc"
    case volume_desc = "volume_desc"
    case id_asc = "id_asc"
    case id_desc = "id_desc"
}

class CGMarketAPI:CoinGeckoAPI,ObservableObject{
    @Published var data:[CoinGeckoMarketData] = []
    var vs_currency:String
    var order:CGMarketOrder
    var per_page:Int
    var page:Int
    var sparkline:Bool
    init(
         vs_currency:String,
         order:CGMarketOrder = .market_cap_desc,
         per_page:Int = 10,
         page:Int = 1,
         sparkline:Bool = true
    ){
        self.vs_currency = vs_currency
        self.order = order
        self.per_page = per_page
        self.page = page
        self.sparkline = sparkline
    }
    
    static var shared:CGCoinAPI = .init(currency: "")
    
    var url:URL?{
        var url_comp = self.baseComponent
        url_comp.path = "/api/v3/coins/markets"
        
        var queryItems = [
            URLQueryItem(name: "vs_currency", value: "\(self.vs_currency)"),
            URLQueryItem(name: "order", value: "\(self.order.rawValue)"),
            URLQueryItem(name: "per_page", value: "\(self.per_page)"),
            URLQueryItem(name: "page", value: "\(self.page)"),
            URLQueryItem(name: "sparkline", value: "\(self.sparkline)")
        ]
        print("queryItems : ",queryItems)
        url_comp.queryItems = queryItems
        print(url_comp.queryItems)
        print("(DEBUG) : ", url_comp)
        return url_comp.url
    }
    
    func getCoinMarketData(completion:((Data) -> Void)? = nil){
        self.getInfo(_url: self.url, completion: completion ?? self.parseCoinMarketData(data:))
    }
    
    
    func parseCoinMarketData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode([CoinGeckoMarketData].self, from: data)
            DispatchQueue.main.async {
                self.data = res
            }
        }catch{
            print("Error while trying to parse data")
        }
    }
    
    
    static func parseCoinMarketData(data:Data) -> CoinGeckoAsset?{
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
