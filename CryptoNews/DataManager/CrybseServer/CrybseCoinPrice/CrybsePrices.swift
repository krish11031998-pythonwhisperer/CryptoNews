//
//  CryptoPrices.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/01/2022.
//

import Foundation

class CrybseMultiCoinPrices:Codable{
    var USD:Float?
}


class CrybseMultiCoinResponse:Codable{
    var data:[String:CrybseMultiCoinPrices]?
    var success:Bool
    var err:String?
}


class CrybseMultiCoinPriceAPI:CrybseAPI{
    @Published var prices:[String:CrybseMultiCoinPrices]?
    var currencies:[String] = []
    
    init(currencies:[String]){
        self.currencies = currencies
    }
    
    var request:URLRequest?{
        return self.requestBuilder(path: "/prices", queries: [URLQueryItem(name: "coins", value: self.currencies.reduce("", {$0 == "" ? $1 : $0+","+$1}))])
    }
    
    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseMultiCoinResponse.self, from: data)
            if let prices = res.data,res.success{
                setWithAnimation {
                    self.prices = prices
                }
            }else if let err = res.err{
                print("(ErrorRequest) There was an error while fetching the data :",err)
            }
        }catch{
            print("(Error) There was an error while trying to parse the CrybseMultiCoinResponse : ",error.localizedDescription)
        }
    }
    
    func getPrices(){
        guard let safeRequest = self.request else {return}
        self.getData(request: safeRequest)
    }
    
}
