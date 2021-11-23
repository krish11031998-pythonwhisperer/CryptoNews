//
//  CoinGeckoAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/10/2021.
//

import Foundation
import Combine

enum CoinGeckoAPIKeys:String{
//    URLQueryItem(name: "community_data", value: "true"),
//    URLQueryItem(name: "developer_data", value: "true"),
//    URLQueryItem(name: "sparkline", value: "true")
    case id = "id"
    case market_data = "market_data"
    case community_data = "community_data"
    case developer_data = "developer_data"
    case sparkline = "sparkline"
}

enum CoinGeckoEndpoints{
    case coin
    case coinMarkets
}

class CoinGeckoAPI:ObservableObject{
    @Published var data:CoinGeckoAsset? = nil
    var currency:String
    var _endpoint:CoinGeckoEndpoints
    var cancellable = Set<AnyCancellable>()
    init(currency:String,endpoint:CoinGeckoEndpoints = .coin){
        self.currency = currency
        self._endpoint = endpoint
    }
    
    func getAsset(){
        print("Getting Gecko Assets Asset  [\(self.baseComponent.url?.absoluteString)]")
        self.getInfo(_url: self.baseComponent.url, completion: self.parseData(data: ))
    }
    
}

extension CoinGeckoAPI{
    
    var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.coingecko.com"
        uC.path = "/api/v3/coins/\(self.endpoint)"
        uC.queryItems = [
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
        ]
        return uC
    }
    
    
    var endpoint:String{
        var endpoint:String = ""
        switch (self._endpoint){
            case .coin: endpoint = "\(self.currency)"
            case .coinMarkets: endpoint = "\(self.currency)/history"
            default: endpoint = "ping"
        }
        return endpoint
    }
    
    static func default_coin_data(baseComponent:URLComponents,currency:String) -> URLComponents{
        var uC = baseComponent
        uC.queryItems?.append(contentsOf: [
            URLQueryItem(name: "id", value: currency),
            URLQueryItem(name: "market_data", value: "true"),
            URLQueryItem(name: "community_data", value: "true"),
            URLQueryItem(name: "developer_data", value: "true"),
            URLQueryItem(name: "sparkline", value: "true")
        ])
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
    
    
    
    func getInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
        if let data = DataCache.shared[url]{
            completion(data)
        }else{
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap(self.checkOutput(output:))
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
                    self.CallCompletionHandler(url: url, data: data, completion: completion)
                })
                .store(in: &cancellable)
        }
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CoinGeckoAsset.self, from: data)
            DispatchQueue.main.async {
                self.data = res
            }
        }catch{
            print("Error while trying to parse data")
        }
        
        
    }
}


