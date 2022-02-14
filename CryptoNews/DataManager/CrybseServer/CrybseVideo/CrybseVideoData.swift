//
//  CrybseVideoData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/02/2022.
//

import Foundation
import UIKit

typealias CrybseVideosData = Array<CrybseVideoData>

extension CrybseVideosData{
    
    static func parseFromData(data:Data) -> CrybseVideosData?{
        var result:CrybseVideosData? = nil
        let decoder = JSONDecoder()
        
        do{
            let res = try decoder.decode(CrybseVideoResponse.self, from: data)
            if let videos = res.data, res.success{
                result = videos
            }
        }catch{
            print("(DEBUG) There was an error while trying to decode the data : ",error.localizedDescription)
        }
        
        return result
    }
}

class CrybseVideoData:Codable{
    
    init(id:CrybseVideoId? = nil){
        self.id = id
    }
    
    class CrybseVideoId:Codable{
        
        init(videoId:String?){
            self.videoId = videoId
        }
        
        var kind:String?
        var videoId:String?
    }
    
    class CrybseThumbnail:Codable{
    
        var url:String?
        var width:Float?
        var height:Float?
    }
    
    class CrybseThumbnails:Codable{

        var medium:CrybseThumbnail?
        var high:CrybseThumbnail?
    }
    
    class CrybseVideoSnippet:Codable{
        var publishedAt:String?
        var channelId:String?
        var title:String?
        var description:String?
        var thumbnails:CrybseThumbnails?
        var channel:String?
        var publish:String?
    }
    
    var kind:String?
    var etag:String?
    var id:CrybseVideoId?
    var snippet:CrybseVideoSnippet?
    
    var thumbnail:String?{
        return self.snippet?.thumbnails?.high?.url ?? "https://i.ytimg.com/vi/OLORVyBHhHI/hqdefault.jpg"
    }
    
    var thumbnailHeight:CGFloat?{
        guard let safeHeight = self.snippet?.thumbnails?.high?.height else {
            return nil
        }
        return CGFloat(safeHeight)
    }
    
    var videoID:String{
        return self.id?.videoId ?? ""
    }
    
    var title:String{
        self.snippet?.title ?? "XRP Will Replace Bitcoin by 2024! (The TRUTH About XRP vs. BITCOIN!)"
    }
    
    static var test:CrybseVideoData = .init(id: .init(videoId: "OLORVyBHhHI"))
}
