//
//  CrybseCoinsAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 31/12/2021.
//

import Foundation


class CrybseAssetsAPI:CrybseAPI{
    
    @Published var coinsData:CrybseAssets? = nil
    var symbols:[String]
    var uid:String
    
    static var shared:CrybseAssetsAPI = .init()
    
    init(symbols:[String]? = nil,uid:String? = nil){
        self.symbols = symbols ?? []
        self.uid = uid ?? ""
    }
    
    var symbolsQuery:String?{
        self.symbols.reduce("", {$0 != "" ? "\($0),\($1)":"\($1)"})
    }
    
    
    var url:URL?{
        var uC =  self.baseComponent
        uC.path = "/getAssets"
        uC.queryItems = [
            URLQueryItem(name: "currency", value: self.symbolsQuery),
            URLQueryItem(name: "uid", value: self.uid)
        ]
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
        print("(DEBUG) Assets url : ",url.absoluteString)
        setWithAnimation {
            if let coin = CrybseAssets.parseAssetsFromData(data: data){
                self.coinsData = coin
            }
            
            if self.loading{
                self.loading.toggle()
            }
            
        }
    }
    
    func getAssets(){
        guard let url = self.url else {
            print("(DEBUG) the url is not right here : ",url?.absoluteString ?? "")
            return
        }
        print("(DEBUG) Getting asset Data : ",self.url?.absoluteString)
        self.getData(_url: url)
    }
    
    func getAssets(symbols:[String],uid:String,completion: @escaping (CrybseAssets?) -> Void){
        self.symbols = symbols
        self.uid = uid
        guard let url = self.url else {return}
        print("(DEBUG) Request => ",url.absoluteString)
        self.getData(_url: url) { data in
            completion(CrybseAssets.parseAssetsFromData(data: data))
        }
    }
    
}
