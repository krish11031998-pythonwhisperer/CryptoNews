//
//  DataAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import Foundation
import Combine

class DAPI{
    
    var cancellable = Set<AnyCancellable>()
    
    func checkOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        if let resp = response as? HTTPURLResponse, resp.statusCode > 200 && resp.statusCode < 300 {
            print("statusCode : \(resp.statusCode)")
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    
    var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.lunarcrush.com"
        uC.path = "/v2"
        uC.queryItems = [
            URLQueryItem(name: "data", value: "assets"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
        ]
        return uC
    }
    
    func getInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: completion)
            .store(in: &cancellable)
    }
    
    
}

class AssetAPI:DAPI,ObservableObject{
    var currency:String
    @Published var data:AssetData? = nil
    
    init(currency:String){
        self.currency = currency
        super.init()
    }
    
    
    var assetURL:URL?{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.lunarcrush.com"
        uC.path = "/v2"
        uC.queryItems = [
            URLQueryItem(name: "data", value: "assets"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
        ]
        uC.queryItems?.append(URLQueryItem(name: "symbol", value: self.currency))
        return uC.url
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(Asset.self, from: data)
            if let first = res.data.first {
                DispatchQueue.main.async {
                    self.data = first
                }
            }
        }catch{
            print("DEBUG MESSAGE FROM DAPI : Error will decoding the data : ",error.localizedDescription)
        }
    }
    
    func getAssetInfo(){
        self.getInfo(_url: self.assetURL, completion: self.parseData(data:))
    }
    
}

class NewsAPI:DAPI,ObservableObject{
    var currency:String
    @Published var newsData:[AssetNewsData] = []
    var source:String
    
    init(currency:String,source:String = "news"){
        self.currency = currency
        self.source = source
        super.init()
    }
    
    
    var newsURL:URL?{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.lunarcrush.com"
        uC.path = "/v2"
        uC.queryItems = [
            URLQueryItem(name: "data", value: "feeds"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
            URLQueryItem(name: "type", value: "influential"),
            URLQueryItem(name: "symbol", value: self.currency),
            URLQueryItem(name: "sources", value: self.source),
            URLQueryItem(name: "limit", value: "15")
        ]
        return uC.url
    }
    
    func parseData(data:Data){
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(News.self, from: data)
            if let news = res.data {
                DispatchQueue.main.async {
                    self.newsData = news
                }
            }
        }catch{
            print("DEBUG MESSAGE FROM DAPI : Error will decoding the data : ",error.localizedDescription)
        }
    }
    
    func getAssetInfo(){
        self.getInfo(_url: self.newsURL, completion: self.parseData(data:))
    }
    
}

