//
//  OHLCVAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 24/12/2021.
//

import Foundation

class CC_OHCLV_API:CryptoCompareAPI{
    
    @Published var ohlcv:CryptoCoinOHLCV? = nil
    var queryItems:[URLQueryItem] = []
    var fsym:String
    var tsym:String
    var aggregate:String?
    var limit:Int
    
    init(fsym:String,tsym:String,aggregate:String? = nil,limit:Int = 50){
        self.fsym = fsym
        self.tsym = tsym
        self.aggregate = aggregate
        self.limit = limit
    }
    
    var queries:[String:Any]{
        return [
            "fsym": fsym,
            "tsym": tsym,
            "aggregate": aggregate,
            "limit":limit
        ]
    }
    
    var request:URLRequest?{        
        return self.requestBuilder(path: "histominute", queries: self.queryBuilder(queries: self.queries), headers: self.CCAPI_requestHeaders)
    }
    
    
    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        
        do{
            let res = try decoder.decode(CryptoCoinOHLCVResponse.self, from: data)
            DispatchQueue.main.async {
                if let ohlcv = res.Data,let response = res.Response, response == "Success" {
                    self.ohlcv = ohlcv
                }
                
                if self.loading{
                    self.loading.toggle()
                }
            }
        }catch{
            print("(DEBUG) There was an error while trying to decode the OHLCV Values : ",error.localizedDescription)
        }
        
    }
    
    func getOHLCV(){
        guard let request = self.request else {return}
        print("(DEBUG) Calling the OHLCV API to get the data url : \(request.url) and headers : \(request.allHTTPHeaderFields)!")
        self.getData(request: request)
    }
    
    
    
}
