//
//  CrybseCoinPrice.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/01/2022.
//

import Foundation

// MARK: - CryptoCoinPrices

struct CrybseCoinPriceResponse:Codable{
    var data:CrybseCoinPrices?
    var success:Bool
    var error:String?
}


typealias CrybseCoinPrices = Array<CrybseCoinPrice>

extension CrybseCoinPrices{
    static func ParseCryptoCoinPricesFromData(data:Data) -> CrybseCoinPrices{
        var prices:CrybseCoinPrices = []
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseCoinPriceResponse.self, from: data)
            if let safePrices = res.data, res.success && !safePrices.isEmpty{
                prices = safePrices
            }else{
                print("(DEBUG) Error while trying to get the prices : ",res.error ?? "The Prices returned is empty")
            }
        }catch{
            print("(DEBUG) Error whule trying to parse the response : ", error.localizedDescription)
        }
        return prices
    }
}


struct CrybseCoinPrice:Codable{
    var time:Float?
    var price:Float?
    var circulatingSupply:Float?
    var date:String?
    
    var Price:Float{
        return self.price ?? 0.0
    }
    
    var Time:Double{
        return Double(self.time ?? 0.0)
    }
    
    var CirculatingSupply:Float{
        return self.circulatingSupply ?? 0.0
    }
    
    var DateValue:String{
        guard let pricetime = self.date else {return Date().stringDate()}
        return Date.date_w_TimeString(isoTime: pricetime)
    }
}
