//
//  CrybseTradingSignalsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/01/2022.
//

import Foundation

class CrybseTradingSignalsData:Codable{
    var symbols:String?
    var partner_symbol:String?
    var inOutVar:CrybseTradingSignalData?
    var largestxsVar:CrybseTradingSignalData?
    var addressesNetGrowth:CrybseTradingSignalData?
    var concentrationVar:CrybseTradingSignalData?
    
    
    var getEmoji:String{
        if self.overall >= 0.75{
            return "😄"
        }else if self.overall <= 0.25{
            return "😞"
        }else{
            return "😐"
        }
    }
    
    var getSentiment:String{
        if self.overall >= 0.75{
            return "Bullish"
        }else if self.overall <= 0.25{
            return "Bearish"
        }else{
            return "Average"
        }
    }
    
    var tradingSignalValues:[String:(Float,String)]{
        
        let tradingSignal = self
        var res:[String:(Float,String)] = [:]
        func getValues(_ data:CrybseTradingSignalData?) -> (Float,String)?{
            guard let score = data?.score, let sentiment = data?.sentiment, score != 0 else {return nil}
            return (score,sentiment)
        }
        
        if let val = getValues(tradingSignal.inOutVar){
            res["In Out Var"] = val
        }
        
        if let val = getValues(tradingSignal.concentrationVar){
            res["Concentration Var"] = val
        }

        if let val = getValues(tradingSignal.largestxsVar){
            res["Largest XS Var"] = val
        }

        if let val = getValues(tradingSignal.addressesNetGrowth){
            res["Addresses Net Growth"] = val
        }

        return res
    }
    
    var overall:Float{
        let signalValue = self.tradingSignalValues
        return signalValue.values.reduce(0, {$0 == 0 ? $1.0 : $0 + $1.0})/Float(signalValue.count)
    }
    
    static func parseFromData(data:Data) -> CrybseTradingSignalsData?{
        var result:CrybseTradingSignalsData? = nil
        let decoder = JSONDecoder()
        do{
            result = try decoder.decode(CrybseTradingSignalsData.self, from: data)
        }catch{
            print("(DEBUG) Error while trying to parse the tradingSignalData from data : ",error.localizedDescription)
        }
        return result
    }
}

class CrybseTradingSignalData:Codable{
    var category:String?
    var sentiment:String?
    var value:Float?
    var score:Float?
    var score_threshold_bearish:Float?
    var score_threshold_bullish:Float?
    
}
