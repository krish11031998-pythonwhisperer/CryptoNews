//
//  CrybseCoinPriceAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/01/2022.
//

import Foundation

class CrybseCoinPriceAPI:CrybseCoinAPI{
    @Published var prices:CrybseCoinPrices? = nil
    init(asset:String,interval:String){
        super.init(type: .coinPrices, params: ["asset":asset,"interval":interval])
    }
    
    static var shared:CrybseCoinPriceAPI = .init(asset: "", interval: "")
    
    
    override func parseData(url: URL, data: Data) {
        let prices =  CrybseCoinPrices.ParseCryptoCoinPricesFromData(data: data)
        if !prices.isEmpty{
            setWithAnimation {
                self.prices = prices
            }
        }
    }
    
    func getPrices(){
        guard let safeRequest = self.request else {return}
        self.getData(request: safeRequest)
    }
    
    
    func getLatestPrices(asset:String,interval:String,completion:((CrybseCoinPrices) -> Void)? = nil){
        let request = self.requestBuilder(path: CrybseCoinAPIEndpoints.coinLatestPrice.rawValue, queries: [.init(name: "asset", value: asset),.init(name: "interval", value: interval)])
        guard let safeRequest = request else {return}
        self.getData(request: safeRequest) { data in
            if self.loading{
                self.loading.toggle()
            }
            completion?(CrybseCoinPrices.ParseCryptoCoinPricesFromData(data: data))
        }
    }
    
    func refreshLatestPrices(asset:String,interval:String,completion:((CrybseCoinPrices) -> Void)? = nil){
        let request = self.requestBuilder(path: CrybseCoinAPIEndpoints.coinLatestPrice.rawValue, queries: [.init(name: "asset", value: asset),.init(name: "interval", value: interval)])
        guard let safeRequest = request else {return}
        self.refreshData(request: safeRequest) { data in
            if self.loading{
                self.loading.toggle()
            }
            completion?(CrybseCoinPrices.ParseCryptoCoinPricesFromData(data: data))
        }
    }
    
}
