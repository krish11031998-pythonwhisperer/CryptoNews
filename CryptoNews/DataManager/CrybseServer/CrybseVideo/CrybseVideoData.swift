//
//  CrybseVideoData.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/02/2022.
//

import Foundation

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
    
    class CrybseVideoId:Codable{
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
        return self.snippet?.thumbnails?.high?.url
    }
    
    var videoID:String{
        return self.id?.videoId ?? ""
    }
    
    var title:String{
        self.snippet?.title ?? "No Title"
    }
}
