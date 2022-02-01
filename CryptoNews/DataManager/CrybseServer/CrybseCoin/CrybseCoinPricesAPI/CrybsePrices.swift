//
//  CryptoPrices.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/01/2022.
//

import Foundation

class CrybseMultiCoinPrice:Codable{
    var USD:Float?
}

typealias CrybseMultiCoinPrices = [String:CrybseMultiCoinPrice]

extension CrybseMultiCoinPrices{
    static func parseMultiCoinPrices(data:Data) -> CrybseMultiCoinPrices?{
        let decoder = JSONDecoder()
        var result:CrybseMultiCoinPrices? = [:]
        do{
            let res = try decoder.decode(CrybseMultiCoinResponse.self, from: data)
            if let prices = res.data,res.success{
                result = prices
            }
        }catch{
            print("(DEBUG) Error while trying to parse the data out : ",error.localizedDescription)
        }
        return result
    }
}


class CrybseMultiCoinResponse:Codable{
    var data:CrybseMultiCoinPrices?
    var success:Bool
    var err:String?
}


class CrybseMultiCoinPriceAPI:CrybseAPI{
    @Published var prices:CrybseMultiCoinPrices?
    var currencies:[String] = []
    
    init(currencies:[String] = []){
        self.currencies = currencies
    }
    
    static var shared:CrybseMultiCoinPriceAPI = .init()
    
    var request:URLRequest?{
        return self.requestBuilder(path: "prices", queries: [URLQueryItem(name: "coins", value: self.currencies.reduce("", {$0 == "" ? $1 : $0+","+$1}))])
    }
    
    override func parseData(url: URL, data: Data) {
        guard let safePrices = CrybseMultiCoinPrices.parseMultiCoinPrices(data: data) else {return}
        setWithAnimation {
            self.prices = safePrices
        }
    }
    
    func getPrices(){
        guard let safeRequest = self.request else {return}
        self.getData(request: safeRequest)
    }
    
    func getPrices(coins:[String],completion:@escaping ((CrybseMultiCoinPrices) -> Void)){
        let request = self.requestBuilder(path: "prices", queries: [URLQueryItem(name: "coins", value: coins.reduce("", {$0 == "" ? $1 : $0+","+$1}))])
        guard let safeRequest = request else {return}
        self.refreshData(request: safeRequest) { data in
            if self.loading{
                setWithAnimation {
                    self.loading.toggle()
                }
            }
            guard let safePrices = CrybseMultiCoinPrices.parseMultiCoinPrices(data: data) else {return}
            completion(safePrices)
        }
    }
    
}
