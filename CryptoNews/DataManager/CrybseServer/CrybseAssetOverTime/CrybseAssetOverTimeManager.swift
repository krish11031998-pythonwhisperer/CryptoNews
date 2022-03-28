//
//  CrybseAssetOverTimeManager.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 18/03/2022.
//

import Foundation


class CrybseAssetOverTimeManager:CrybseAPI{
    
    @Published var assetOverTime:CrybseAssetOverTime? = nil
    var uid:String
    
    init(uid:String = "uid"){
        self.uid = uid
    }
    
    static var shared:CrybseAssetOverTimeManager = .init()
    
    func generateRequestURL(_ _uid:String?) -> URLRequest?{
        let request = self.requestBuilder(path: "getAssetsValueOverTime",queries: [.init(name: "uid", value: _uid ?? self.uid)])
        return request
    }
    
    override func parseData(url: URL, data: Data) {
        if let assetOverTime = CrybseAssetOverTime.parseCrybseAssetOverTime(data: data){
            setWithAnimation {
                self.assetOverTime = assetOverTime
            }
            
            if self.loading{
                self.loading.toggle()
            }
        }
    }
    
    func getPortfolioOverTime(uid:String? = nil,completion:((Data) -> Void)? = nil){
        guard let request = self.generateRequestURL(uid) else {return}
        print("(DEBUG) url for PortfolioAssetOverTime : ",request.url?.absoluteString ?? "No Request URL")
        self.getData(request:request,completion: completion)
    }

}

