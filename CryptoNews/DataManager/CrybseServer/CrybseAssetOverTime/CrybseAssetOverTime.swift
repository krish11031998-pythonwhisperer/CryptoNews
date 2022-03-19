//
//  CrybseAssetOverTime.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 18/03/2022.
//

import Foundation


struct CrybseAssetOverTimeResponse:Codable{
    var data:CrybseAssetOverTime?
//    var err:String?
    var success:Bool
}

struct CrybseAssetOverTime:Codable{
    var currentPortfolioValue:Float?
    var portfolioTimeline:[Float]?
    var profit:Float?
    var change:Float?
    var invested:Float?
    
    var CurrentPortfolioValue:Float{
        return self.currentPortfolioValue ?? 0
    }
    
    var PortfolioTimeline:[Float]{
        self.portfolioTimeline ?? []
    }
    
    var Profit:Float{
        return self.profit ?? 0
    }
    
    var Change:Float{
        return self.change ?? 0
    }
    
    var Invested:Float{
        return self.invested ?? 0
    }
    
    
    static func parseCrybseAssetOverTime(data:Data) -> CrybseAssetOverTime?{
        let decoder = JSONDecoder()
        var result:CrybseAssetOverTime? = nil
        do{
            let response = try decoder.decode(CrybseAssetOverTimeResponse.self, from: data)
            if let res = response.data, response.success{
                result = res
            }
        }catch{
            print("(DEBUG) Error : while decoding the response of the Portofolio over time eendpoint => ",error.localizedDescription)
        }
        
        return result
    }
    
    func getPortfolioPriceAtTime(idx:Int = -1) -> Float?{
        if idx >= 0 && idx < self.PortfolioTimeline.count{
            return self.PortfolioTimeline[idx]
        }
        return self.currentPortfolioValue
    }
}
