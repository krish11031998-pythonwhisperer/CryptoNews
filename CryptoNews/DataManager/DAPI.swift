//
//  DAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation
import Combine

protocol DataParsingProtocol{
    func parseData(url:URL,data:Data)
}


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


class DAPI:ObservableObject,DataParsingProtocol{
    func parseData(url: URL, data: Data) {
        DataCache.shared[url] = data
    }
    
    
    @Published var loading:Bool = false
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
        DataCache.shared[url] = data
        completion(data)
        DispatchQueue.main.async {
            self.loading = false
        }
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
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: { data in

                self.CallCompletionHandler(url: url, data: data, completion: completion)
            })
            .store(in: &cancellable)
    }
    
    func getData(_url:URL?){
        if !self.loading{
            DispatchQueue.main.async {
                self.loading = true
            }
        }
        guard let url = _url else {return}
        if let data = DataCache.shared[url]{
            DispatchQueue.main.async {
                self.loading = false
                self.parseData(url: url, data: data)
            }
        }else{
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap(self.checkOutput(output:))
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
                    self.parseData(url: url, data: data)
                })
                .store(in: &cancellable)
        }
    }
    
    
    func getData(_url:URL?,completion:@escaping (Data)->Void){
        if !self.loading{
            DispatchQueue.main.async {
                self.loading = true
            }
        }
        guard let url = _url else {return}
        if let data = DataCache.shared[url]{
            DispatchQueue.main.async {
                self.loading = false
            }
            completion(data)
        }else{

            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap(self.checkOutput(output:))
                .sink(receiveCompletion: { _ in }, receiveValue: { data in
                    DataCache.shared[url] = data
                    completion(data)
                })
                .store(in: &cancellable)
        }
    }
    
    
}
