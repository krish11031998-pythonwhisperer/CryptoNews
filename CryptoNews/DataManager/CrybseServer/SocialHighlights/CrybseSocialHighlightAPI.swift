//
//  SocialHighlightAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 02/04/2022.
//

import Foundation

class CrybseSocialHighlightsAPI:CrybseAssetSocialsAPI{
    var assets:[String]
    
    init(assets:[String]){
        self.assets = assets
        super.init(type: .socialHighlights, queryItems: ["asset":assets])
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
}
