//
//  CrybseVideoAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/02/2022.
//

import Foundation

class CrybseVideoResponse:Codable{
    var data:Array<CrybseVideoData>?
    var err:String?
    var success:Bool
    
    static func parseVideoDataFromData(data:Data) -> Array<CrybseVideoData>?{
        let decoder = JSONDecoder()
        var videos:Array<CrybseVideoData>?
        
        do{
            let response = try decoder.decode(CrybseVideoResponse.self, from: data)
            if let safeVideos = response.data, response.success{
                videos = safeVideos
            }
            
        }catch{
            print("(DEBUG) Error while trying to parse the CrybseVideoResponse : ",error.localizedDescription)
        }
        return videos
    }
}

class CrybseVideoAPI:CrybseAPI{
    
    @Published var videos:[CrybseVideoData] = []
    var q:String
    var limit:Int
    
    static var shared:CrybseVideoAPI = .init(q: "")
    
    init(q:String?,limit:Int = 15){
        self.q = q ?? ""
        self.limit = limit
        super.init()
    }
    
    var request:URLRequest?{
        self.requestBuilder(path: "youtube", queries: [.init(name: "search", value: self.q),.init(name: "limit", value: String(self.limit))])
    }
    
    override func parseData(url: URL, data: Data) {
        guard let videos = CrybseVideosData.parseFromData(data: data) else {return}
        setWithAnimation {
            self.videos = videos
        }
    }
    
    func getVideos(){
        guard let safeRequest = self.request else {return}
        self.getData(request: safeRequest)
    }
    
    func getVideos(q:String,completion:@escaping (CrybseVideosData?) -> Void){
        let request = self.requestBuilder(path: "youtube", queries: [.init(name: "search", value: q)])
        guard let safeRequest = request else {return}
        self.getData(request: safeRequest) { data in
            completion(CrybseVideosData.parseFromData(data: data))
        }
    }
}
