//
//  DAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
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
////            URLQueryItem(name: "data", value: "assets"),
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
        ]
        return uC
    }
    
    func getInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
        print("(DEBUG) Calling this URL : ",url)
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: completion)
            .store(in: &cancellable)
    }
    
    
}
