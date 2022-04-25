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
    
    var SourceName:String{
        self.source_name ?? ""
    }
    
    var _Type:String{
        self.type ?? ""
    }
    
    var VideoID:String?{
        if let safeType = self.type,
           let safeNewsURL = self.news_url,
           let safeVideoID = safeNewsURL.split(separator: "=").last,
           safeType.lowercased() == "video"
        {
            return String(safeVideoID)
        }else{
            return nil
        }
    }
    enum CodingKeys:CodingKey{
        case news_url
        case image_url
        case title
        case text
        case source_name
        case date
        case topic
        case sentiment
        case type
        case tickers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        news_url = try container.decodeIfPresent(String.self, forKey: .news_url)
        image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        source_name = try container.decodeIfPresent(String.self, forKey: .source_name)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        topic = try container.decodeIfPresent([String].self, forKey: .topic)
        sentiment = try container.decodeIfPresent(String.self, forKey: .sentiment)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        tickers = try container.decodeIfPresent([String].self, forKey: .tickers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(news_url, forKey: .news_url)
        try container.encode(image_url, forKey: .image_url)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(source_name,forKey: .source_name)
        try container.encode(date,forKey: .date)
        try container.encode(topic,forKey: .topic)
        try container.encode(sentiment,forKey: .sentiment)
        try container.encode(type,forKey: .type)
        try container.encode(tickers,forKey: .tickers)
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
