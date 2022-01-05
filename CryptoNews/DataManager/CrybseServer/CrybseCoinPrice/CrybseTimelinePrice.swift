//
//  CrybseTimelinePrice.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 05/01/2022.
//

import Foundation


class CrybseTimeseriesPriceResponse:Codable{
    var data:[CryptoCoinOHLCVPoint]?
    var success:Bool
    var err:String?
}


class CrybseTimeseriesPriceAPI:CrybseAPI{
    @Published var timeseriesData:[CryptoCoinOHLCVPoint]? = nil
    var currency:String
    var start:Int?
    var end:Int?
    var limit:Int
    var fiat:String
    init(currency:String? = nil,start:Int? = nil,end:Int? = nil,limit:Int = 10,fiat:String = "USD"){
        self.currency = currency ?? ""
        self.start = start
        self.end = end
        self.limit = limit
        self.fiat = fiat
    }
    
    static var shared:CrybseTimeseriesPriceAPI = .init()
    
    var params:[URLQueryItem]{
        var paramsMap:[String:Any] = ["crypto":self.currency,"start":start,"end":end,"limit":limit,"fiat":fiat]
        return paramsMap.compactMap({
            if let val = $1 as? Int{
                return URLQueryItem(name: $0, value: "\(val)")
            }else if let val = $1 as? String{
                return URLQueryItem(name: $0, value: val)
            }else{
                return nil
            }
        })
    }
    
    var url:URL?{
        var uC = self.setPath(path:"/getHistoricalData")
        uC.queryItems = self.params
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseTimeseriesPriceResponse.self, from: data)
            if let timelineData = res.data, res.success{
                setWithAnimation {
                    self.timeseriesData = timelineData
                }
                if self.loading{
                    self.loading.toggle()
                }
            }else if let err = res.err{
                print("Error in the response : ",err)
            }
        }catch{
            print("(ERROR) While trying to parse the timeseries from Data",error.localizedDescription)
        }
    }
    
    static func parseData(data: Data) -> [CryptoCoinOHLCVPoint]?{
        var TSdata:[CryptoCoinOHLCVPoint]? = nil
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CrybseTimeseriesPriceResponse.self, from: data)
            if let timelineData = res.data, res.success{
                TSdata = timelineData
            }else if let err = res.err{
                print("Error in the response : ",err)
            }
        }catch{
            print("(ERROR) While trying to parse the timeseries from Data",error.localizedDescription)
        }
        
        return TSdata
    }
    
    
    func getTimeseriesPrice(){
        guard let url = self.url else {return}
        self.getData(_url: url)
    }
    
    func getPrice(currency:String,start:Int? = nil,end:Int? = nil,limit:Int = 10,fiat:String = "USD",completion: @escaping (Data) -> Void){
        self.currency = currency
        self.start = start
        self.end = end
        self.fiat = fiat
        self.limit = limit
        self.refreshData(_url: self.url, completion: completion)
    }
    
}
