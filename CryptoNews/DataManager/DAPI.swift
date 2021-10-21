//
//  DAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation
import Combine

protocol DataDictCache{
    subscript(_ url:URL) -> Data? {get set}
}

struct DataCache:DataDictCache{
    
    private var cache:NSCache<NSURL,NSData> = .init()
    
    static var shared:DataCache = .init()
    
    
    subscript(url: URL) -> Data? {
        get {
            var res:Data? = nil
            if let ns_url = url as? NSURL, let data = self.cache.object(forKey: ns_url) as? Data{
                res = data
            }
            return res
        }
        set {
            if let nsData = newValue as? NSData, let ns_url = url as? NSURL{
                self.cache.setObject(nsData, forKey: ns_url)
            }
        }
    }
}


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
    
    
    func CallCompletionHandler(url:URL,data:Data,completion:((Data) -> Void)){
//        print("Setting Cached Data")
        DataCache.shared[url] = data
        completion(data)
    }
    
    
    var baseComponent:URLComponents{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "api.lunarcrush.com"
        uC.path = "/v2"
        uC.queryItems = [
            URLQueryItem(name: "key", value: "cce06yw0nwm0w4xj0lpl5pg"),
        ]
        return uC
    }
    
    func updateInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
//        print("Getting Updated Data")
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: { data in
//                print("Got Updated Data")
                self.CallCompletionHandler(url: url, data: data, completion: completion)
            })
            .store(in: &cancellable)
    }
    
    func getInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
        if let data = DataCache.shared[url]{
//            print("Got Cached Data")
            completion(data)
        }else{
//            print("Getting New Data")
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap(self.checkOutput(output:))
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
//                    print("Got New Data")
                    self.CallCompletionHandler(url: url, data: data, completion: completion)
                })
                .store(in: &cancellable)
        }
    }
    
    
}
