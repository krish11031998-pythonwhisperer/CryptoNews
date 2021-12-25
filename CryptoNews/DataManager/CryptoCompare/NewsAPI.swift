//
//  NewsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 25/12/2021.
//

import Foundation


class CryptoNewsAPI:CryptoCompareAPI{
    
    @Published var news:[CryptoNews]? = nil
    var feeds:String?
    var categories:[String]?
    var excludeCategories:String?
    var lang:String?
    var sortOrder:String?
    
    init(feeds:String? = nil,categories:[String]? = nil,excludeCategories:String? = nil,sortOrder:String?){
        self.feeds = feeds
        self.categories = categories
        self.excludeCategories = excludeCategories
        self.sortOrder = sortOrder
    }
    
    var queries:[String:Any]{
        return ["feeds":feeds,"categories":categories,"excludeCategories":excludeCategories,"sortOrder":sortOrder]
    }
    
    var request:URLRequest?{
        return self.requestBuilder(path: "news", queries: self.queryBuilder(queries: self.queries), headers: self.CCAPI_requestHeaders)
    }
    
    override func parseData(url: URL, data: Data) {
        let decoder = JSONDecoder()
        do{
            let res = try decoder.decode(CryptoNewsResponse.self, from: data)
            DispatchQueue.main.async {
                if let data = res.Data{
                    self.news = data
                }
                
                if self.loading{
                    self.loading.toggle()
                }
            }
        }catch{
            print("(DEBUG) There was an error while trying to decode CryptoNewsResponse : ",error.localizedDescription)
        }
    }
    
    
    func getNews(){
        guard let request = request else {
            return
        }
        self.getData(request: request)
    }
    
}
