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
}

class CrybseVideoAPI:CrybseAPI{
    
    @Published var videos:[CrybseVideoData] = []
    var q:String
    
    static var shared:CrybseVideoAPI = .init(q: "")
    
    init(q:String?){
        self.q = q ?? ""
        super.init()
    }
    
    var request:URLRequest?{
        self.requestBuilder(path: "/videos", queries: [.init(name: "q", value: self.q)])
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
        let request = self.requestBuilder(path: "/videos", queries: [.init(name: "q", value: q)])
        guard let safeRequest = request else {return}
        self.getData(request: safeRequest) { data in
            completion(CrybseVideosData.parseFromData(data: data))
        }
    }
}
