//
//  DAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import Foundation
import Combine

public protocol DataParsingProtocol{
    
    func parseData(url:URL,data:Data)
}

public protocol DataDictCache{
    subscript(_ url:URL) -> Data? {get set}
}

public struct DataCache:DataDictCache{
    
    private var cache:NSCache<NSURL,NSData> = .init()
    
    static var shared:DataCache = .init()
    
    
    public subscript(url: URL) -> Data? {
        get {
            let ns_url = url as NSURL
            return self.cache.object(forKey: ns_url) as Data?
        }
        
        set {
            
            guard let nsData = newValue as NSData? else {return}
            let ns_url = url as NSURL
            if let _  = self.cache.object(forKey: ns_url){
                self.cache.removeObject(forKey: ns_url)
            }
            self.cache.setObject(nsData, forKey: ns_url)
        }
    }
}

public struct RequestData:Codable{
    var data:String?
    var success:Bool
    
    public init(data:String?,success:Bool){
        self.data = data
        self.success = success
    }
}

public class DAPI:ObservableObject,DataParsingProtocol{

    public func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(RequestData.self, from: data)
            DispatchQueue.main.async {
                self.success = res.success
            }
        }catch{
            print("(DEBUG) Error while trying to parse teh Request Data from the data : ",error.localizedDescription)
        }
    }
    
    @Published var success:Bool?
    @Published var loading:Bool
    var cancellable = Set<AnyCancellable>()
    
    public init(){
        self._success = .init(initialValue: nil)
        self._loading = .init(initialValue: false)
    }

    public var baseComponent:URLComponents{
        return URLComponents()
    }
    
    public func checkOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        if let resp = response as? HTTPURLResponse, resp.statusCode > 400 && resp.statusCode < 500 {
            print("statusCode : \(resp.statusCode)")
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    public func parseQueryItems(queryItems: inout[URLQueryItem],key:String,query:Any){
        var finalQuery:[URLQueryItem] = []
        if let value = query as? String{
            finalQuery.append(.init(name: key, value: value))
        }else if let values = query as? [String]{
            finalQuery = values.compactMap({.init(name: "\(key)=", value: $0)})
        }else if let value = query as? Int{
            finalQuery.append(.init(name: key, value: "\(value)"))
        }else{
            return
        }
        
        queryItems.append(contentsOf: finalQuery)

    }
    
    public func queryBuilder(queries:[String:Any]) -> [URLQueryItem]{
        var queryItems:[URLQueryItem] = []
        for (key,query) in queries{
            self.parseQueryItems(queryItems: &queryItems, key: key, query: query)
        }
        return queryItems
    }
    
    public func requestBuilder(path:String? = nil,queries:[URLQueryItem]?,headers:[String:String]? = nil) -> URLRequest?{
        var urlComp = self.baseComponent
        if let path = path {
            urlComp.path += "/\(path)"
        }
        
        if let queries = queries {
            urlComp.queryItems = queries
        }
        
        guard let url = urlComp.url else {return nil}
        var request = URLRequest(url: url)
        self.addHeadersFieldstoRequest(request: &request, _headers: headers)
        print("(DEBUG) Request => URL : \(url) with headers : \(request.allHTTPHeaderFields)")
        return request
    }
    
    public func addHeadersFieldstoRequest(request: inout URLRequest,_headers:[String:String]? = nil){
        guard let headers = _headers else {return}
        for (key,value) in headers{
            request.addValue(value, forHTTPHeaderField: key)
        }

    }
    
    public func CallCompletionHandler(url:URL,data:Data,completion:((Data) -> Void)){
//        DataCache.shared[url] = data
        completion(data)
        DispatchQueue.main.async {
            self.loading = false
        }
    }

    
    public func performDataRequest(url:URL? = nil,request:URLRequest? = nil,completion:((Data) -> Void)? = nil){
        let publisher:URLSession.DataTaskPublisher
        if let url = url {
             publisher = URLSession.shared.dataTaskPublisher(for: url)
        }else if let request = request{
            publisher = URLSession.shared.dataTaskPublisher(for: request)
        }else{
            return
        }
                
        publisher
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] data in
                let url = request?.url ?? url ?? URL(string: "")!
                if request?.httpMethod == "GET"{
                    DataCache.shared[url] = data
                }
                if let safeCompletion = completion {
                    self?.CallCompletionHandler(url: url, data: data, completion: safeCompletion)
                }else{
                    self?.parseData(url: url, data: data)
                }
                
            })
            .store(in: &cancellable)
        
    }
    
    public func updateInfo(_url:URL?,completion:@escaping ((Data) -> Void)){
        guard let url = _url else {return}
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkOutput(output:))
            .sink(receiveCompletion: { _ in }, receiveValue: { data in

                self.CallCompletionHandler(url: url, data: data, completion: completion)
            })
            .store(in: &cancellable)
    }
    
    
    public func getData(_url:URL? = nil,request:URLRequest? = nil,completion:((Data) -> Void)? = nil){
        if !self.loading{
            DispatchQueue.main.async {
                self.loading = true
            }
        }
        
        let finalURL = request?.url ?? _url ?? .none
        if let safeURL = finalURL,let data = DataCache.shared[safeURL]{
            DispatchQueue.main.async {
                self.loading = false
                self.parseData(url: safeURL, data: data)
            }
        }else{
            self.performDataRequest(url:_url,request: request, completion: completion)
        }
    }
    
    public func refreshData(_url:URL? = nil,request:URLRequest? = nil,completion:((Data) -> Void)? = nil){
        if !self.loading{
            DispatchQueue.main.async {
                self.loading = true
            }
        }
        self.performDataRequest(url:_url,request: request, completion: completion)
    }
    
// MARK: - Posting Data
    
    public func PostData(url:URL? = nil,request req:URLRequest? = nil,parseFunc:((Data) -> Void)? = nil,completion:((Any) -> Void)? = nil){
        var request:URLRequest
        
        if let safeRequest = req{
            request = safeRequest
        }else if let safeURL = url{
            request = URLRequest(url: safeURL)
            request.httpMethod = "POST"
        }else{
            print("(DEBUG) You have provided not URL OR Request")
            return
        }
        
        if let safeParseFunc = parseFunc{
            self.performDataRequest(request: request,completion:safeParseFunc)
        }else{
            self.performDataRequest(request: request) { data in
                let decoder = JSONDecoder()
                do{
                    let res = try decoder.decode(RequestData.self, from: data)
                    completion?(res)
                }catch{
                    print("(DEBUG) Error while trying to parse the RequestData! : ",error.localizedDescription)
                }
            }
        }
    }
    
}
