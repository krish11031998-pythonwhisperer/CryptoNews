//
//  CrybsePrice.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/01/2022.
//

import Foundation

class CrybseCoinPrice:Codable,Equatable{
    static func == (lhs: CrybseCoinPrice, rhs: CrybseCoinPrice) -> Bool {
        return lhs.Currency == rhs.Currency && lhs.USD == rhs.USD
    }
    
    var Currency:String?
    var USD:Float?
    
    var Price:Float{
        return self.USD ?? 0
    }
}

class CrybseCoinPriceResponse:Codable{
    var data:[String:[CryptoCoinOHLCVPoint]]?
    var success:Bool
    var err:String?
    
}


class CrybsePriceAPI:CrybseAPI{
    
    enum Mode{
        case single
        case multiple
    }
    
    @Published var singlePriceData:CryptoCoinOHLCVPoint? = nil
    @Published var multiPriceData:[String:[CryptoCoinOHLCVPoint]]? = nil
    var mode:CrybsePriceAPI.Mode
    var coin:String? = nil
    var coins:[String]? = nil
    
    init(coin:String? = nil,coins:[String]? = nil,mode:CrybsePriceAPI.Mode = .single){
        self.coin = coin
        self.coins = coins
        self.mode = mode
    }
    
    static var shared:CrybsePriceAPI = .init()
    
    var url:URL?{
        let currencies = self.mode == .single ? self.coin : self.coins?.reduce("", {$0 == "" ? $1 : "\($0),\($1)"})
        guard let currencies = currencies else {return nil}
        var uC = self.setPath(uc: self.baseComponent, path: "/ohlcv/latestOHLCVCoinPrices")
        uC.queryItems = [
            URLQueryItem(name: "currencies", value: self.coin)
        ]
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
        if let data = self.parsePriceData(url: url, data: data){
            setWithAnimation {
                if self.mode == .single{
                    if let coin = self.coin, let price = data[coin]?.last{
                        self.singlePriceData = price
                    }
                }else if self.mode == .multiple{
                    self.multiPriceData = data
                }
            }
        }
    }
    
    func parsePriceData(url:URL,data:Data) -> [String:[CryptoCoinOHLCVPoint]]?{
        var result:[String:[CryptoCoinOHLCVPoint]]?
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinPriceResponse.self, from: data)
            if let data = res.data,res.success{
                result = data
            }
        }catch{
            print("There was an issue with parsing the crybsePrice : ",error.localizedDescription)
        }
        return result
    }
    
    func getPrice(){
        guard let url = self.url else {return}
        self.getData(_url: url)
    }
    
    func getSinglePrice(curr:String,completion:@escaping ((CryptoCoinOHLCVPoint?) -> Void)){
        var url_Components = self.setPath(uc: self.baseComponent, path: "/ohlcv/latestOHLCVCoinPrices")
        url_Components.queryItems = [URLQueryItem(name: "currencies", value: curr)]
        guard let url = url_Components.url else {return}
        print("(DEBUG) price URL : ",url)
        self.getData(_url: url) { data in
            if let data = self.parsePriceData(url: url, data: data),let lastPrice = data[curr]?.last{
                completion(lastPrice)
            }
        }
    }
    
    func getMultiplePrice(curr:[String],completion:@escaping ([String:[CryptoCoinOHLCVPoint]]?) -> Void){
        var url_Components = self.setPath(uc: self.baseComponent, path: "/ohlcv/latestOHLCVCoinPrices")
        url_Components.queryItems = [URLQueryItem(name: "currencies", value: curr.reduce("", {$0 == "" ? $1 : "\($0 + "," + $1)"}))]
        guard let url = url_Components.url else {return}
        print("(DEBUG) price URL : ",url)
        self.getData(_url: url) { data in
            if let prices = self.parsePriceData(url: url, data: data){
                completion(prices)
            }
        }
    }
}

