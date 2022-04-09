//
//  CrybseNewsData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/04/2022.
//

import SwiftUI

class CrybseNewsResponse:Codable{
    var data:CrybseNewsList?
    var err:String?
    var success:Bool
}

class CrybseNews:Codable{
    var news_url:String?
    var image_url:String?
    var title:String?
    var text:String?
    var source_name:String?
    var date:String?
    var topic:[String]?
    var sentiment:String?
    var type:String?
    var tickers:[String]?
    
    var NewsURL:String{
        self.news_url ?? ""
    }
    
    var ImageURL:String{
        self.image_url ?? ""
    }
    
    var Date:String{
        self.date ?? ""
    }
    
}

typealias CrybseNewsList = Array<CrybseNews>

extension CrybseNewsList{
    
    static func parseNewsDataList(data:Data) -> CrybseNewsList?{
        let decoder = JSONDecoder()
        var result:CrybseNewsList? = nil
        
        do{
            let response = try decoder.decode(CrybseNewsResponse.self, from: data)
            if response.success, let newsList = response.data{
                result = newsList
            }
        }catch{
            print("(DEBUG) Error while parsing the data : ",error.localizedDescription)
        }
        
        return result
    }

}
