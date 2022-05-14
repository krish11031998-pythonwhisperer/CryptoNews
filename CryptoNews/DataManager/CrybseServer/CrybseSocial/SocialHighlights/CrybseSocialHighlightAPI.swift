//
//  SocialHighlightAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/04/2022.
//

import Foundation

class CrybseSocialHighlightsAPI:CrybseAssetSocialsAPI{
    var assets:[String]
    var keywords:[String]
    
    init(assets:[String]? = nil,keywords:[String]? = nil){
        self.assets = assets ?? []
        self.keywords = keywords ?? []
        super.init(type: .socialHighlights, queryItems: ["asset":assets ?? [],"keyword":keywords ?? []])
    }
    
    static var shared:CrybseSocialHighlights = .init()
    
    var socialHightlight:CrybseSocialHighlights?{
        if let socialHighlights = self.data as? CrybseSocialHighlights{
            return socialHighlights
        }else{
            return nil
        }
    }
    
    func getSocialHighlights(type:CrybseAssetSocialType? = nil,endpoint:CrybseTwitterEndpoints? = nil,queryItems:[String:Any]? = nil,completion:((Data?) -> Void)? = nil){
        self.getAssetSocialData(type: type, endpoint: endpoint?.rawValue, queryItems: queryItems, completion: completion)
    }
    
    static func loadStaticSocialHighlights() -> CrybseSocialHighlights?{
        if let safeData = readJsonFile(forName: "socialHighlights"){
            if let safeSocialHighlights = CrybseSocialHighlightResponse.parseHighlightsFromData(data: safeData){
                return safeSocialHighlights
            }
        }else{
            print("JSON file with the name : socialHighlights is not available")
        }
        return nil
    }
}
