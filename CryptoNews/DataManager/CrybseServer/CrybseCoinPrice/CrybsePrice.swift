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
    var data:CrybseCoinPrice?
    var success:Bool
}


class CrybsePriceAPI:CrybseAPI{
    
    @Published var priceData:CrybseCoinPrice? = nil
    
    var coin:String
    
    init(coin:String? = nil){
        self.coin = coin ?? ""
    }
    
    static var shared:CrybsePriceAPI = .init()
    
    var url:URL?{
        var uC = self.setPath(uc: self.baseComponent, path: "/price")
        uC.queryItems = [
            URLQueryItem(name: "coin", value: self.coin)
        ]
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
        if let data = self.parsePriceData(url: url, data: data){
            setWithAnimation {
                self.priceData = data
            }
        }
    }
    
    func parsePriceData(url:URL,data:Data) -> CrybseCoinPrice?{
        var result:CrybseCoinPrice?
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
    
    func getPrice(curr:String,completion:@escaping ((CrybseCoinPrice?) -> Void)){
        var url_Components = self.setPath(uc: self.baseComponent, path: "/price")
        url_Components.queryItems = [URLQueryItem(name: "coin", value: curr)]
        guard let url = url_Components.url else {return}
        print("(DEBUG) price URL : ",url)
        self.getData(_url: url) { data in
            completion(self.parsePriceData(url: url, data: data))
        }
    }
}

