//
//  CrybseNewsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/04/2022.
//

import Foundation

enum NewsEndpoint:String{
    case tickerNews = "tickerNews"
}

class CrybseNewsAPI:CrybseAssetSocialsAPI{
    
    @Published var newsList:CrybseNewsList? = nil
    
    init(endpoint:NewsEndpoint = .tickerNews,tickers:String? = nil,type:String = "Article"){
        
        super.init(type: .news, endpoint: endpoint.rawValue, queryItems: ["tickers":tickers,"type":type])
    }
    
    static var shared:CrybseNewsAPI = .init()
    
    var NewsList:CrybseNewsList{
        self.newsList ?? []
    }
    
    override func parseData(url: URL, data: Data) {
        if let newsList = CrybseNewsList.parseNewsDataList(data: data){
            setWithAnimation {
                self.newsList = newsList
            }
        }
    }
    
    func getNews(tickers:String? = nil,type:String? = nil,completion: ((Data?) -> Void)? = nil){
        var queries:[String:Any]? = nil
        if let tickers = tickers{
            if queries == nil{
                queries  = [:]
            }
            queries?["tickers"] = tickers
        }
        if let type = type{
            if queries == nil{
                queries  = [:]
            }
            queries?["type"] = type
        }
        
        guard let safeRequest = self.request(queryItems: queries) else {return}
        
        self.getData(request: safeRequest, completion: completion)
    }
    
    
    
}
