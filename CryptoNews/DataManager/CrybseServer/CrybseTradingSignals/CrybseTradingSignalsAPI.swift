//
//  CrybseTradingSignalsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/01/2022.
//

import Foundation

class CrybseTradingSignalsAPI:CrybseAPI{
    @Published var tradingSignals:CrybseTradingSignalsData? = nil
    
    var currency:String
    
    init(currency:String){
        self.currency = currency
    }
    
    var url:URL?{
        var uC = self.setPath(path: "/coin/tradingSignals")
        uC.queryItems = [
            URLQueryItem(name: "currency", value: self.currency)
        ]
        return uC.url
    }
    
    
    override func parseData(url: URL, data: Data) {
        setWithAnimation {
            if let safeTradingSignals = CrybseTradingSignalsData.parseFromData(data: data){
                self.tradingSignals = safeTradingSignals
            }
            
            if self.loading{
                self.loading.toggle()
            }
        }
    }
    
    func getTradingSignals(){
        guard let url = self.url else {return}
        self.getData(_url: url)
    }
    
    
    func getTradingSignals(currency:String,completion: @escaping ((CrybseTradingSignalsData?) -> Void)){
        var uC = self.setPath(path: "/coin/tradingSignals")
        uC.queryItems = [
            URLQueryItem(name: "currency", value: currency)
        ]
        guard let safeURL = uC.url else {return}
        self.getData(_url: safeURL) { data in
            if let safeTradingSignalData = CrybseTradingSignalsData.parseFromData(data: data){
                completion(safeTradingSignalData)
            }
        }
    }
    
    
}
