//
//  CoinGeckoAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/10/2021.
//

import Foundation
import Combine

//struct CoinGeckoEndpointQueries:Codable{
//    var vs_currency:String?
//    var ids:String?
//    var id:String?
//    var category:String?
//    var order:String?
//    var per_page:Int?
//    var page:Int?
//    var sparkline:Bool?
//    var price_change_percentage:String?
//    var localization:String?
//    var market_data:Bool?
//    var community_data:Bool?
//    var develop_data:Bool?
//
//}


enum CoinGeckoEndpoints{
    case coin
    case coinMarkets
}

class CoinGeckoAPI{
    var cancellable = Set<AnyCancellable>()
    func getAsset(){
        print("Getting Gecko Assets Asset  [\(self.baseComponent.url?.absoluteString)]")
        self.getInfo(_url: self.baseComponent.url)
    }
    
}

extension CoinGeckoAPI{
    
    var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.coingecko.com"
        return uC
    }
    
    
    func CallCompletionHandler(url:URL,data:Data,completion:((Data) -> Void)){
        DataCache.shared[url] = data
        completion(data)
    }
    
    func checkOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        if let resp = response as? HTTPURLResponse, resp.statusCode > 200 && resp.statusCode < 300 {
            print("statusCode : \(resp.statusCode)")
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    func getInfo(_url:URL?,completion:((Data) -> Void)? = nil){
        guard let url = _url else {return}
        if let data = DataCache.shared[url]{
            completion?(data)
        }else{
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap(self.checkOutput(output:))
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
                    if let completion = completion {
                        self.CallCompletionHandler(url: url, data: data, completion: completion)
                    }
                })
                .store(in: &cancellable)
        }
    }
    
}


