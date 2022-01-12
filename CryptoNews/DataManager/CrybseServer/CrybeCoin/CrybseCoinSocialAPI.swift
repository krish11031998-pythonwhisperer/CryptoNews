//
//  CrybseCoinAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/12/2021.
//

import Foundation


class CrybseCoinSocialAPI:CrybseAPI{
    
    @Published var coinData:CrybseCoinSocialData? = nil
    
    var coinUID:String = ""
    var fiat:String = ""
    var crypto:String = ""
    
    init(coinUID:String,fiat:String,crypto:String){
        self.coinUID = coinUID
        self.fiat = fiat
        self.crypto = crypto
    }
    
    static var shared:CrybseCoinSocialAPI = .init(coinUID: "", fiat: "", crypto: "")
    
    var url:URL?{
        var uC = self.baseComponent
        uC.path = "/coinData"
        uC.queryItems = [
            URLQueryItem(name: "coinUID", value: coinUID),
            URLQueryItem(name: "fiat", value: fiat),
            URLQueryItem(name: "crypto", value: crypto)
        ]
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
//        DataCache.shared[url] = data
        print("(DEBUG) coinData url : ",url.absoluteString)
        setWithAnimation {
            if let data = CrybseCoinSocialData.parseCoinDataFromData(data: data){
                self.coinData = data
            }
            
            if self.loading{
                self.loading.toggle()
            }
        }
    }
    
    func getCoinData(coinUID:String,fiat:String,crypto:String,completion:((Data) -> Void)?){
        var uC = self.baseComponent
        uC.path = "/coinData"
        uC.queryItems = [
            URLQueryItem(name: "coinUID", value: coinUID),
            URLQueryItem(name: "fiat", value: fiat),
            URLQueryItem(name: "crypto", value: crypto)
        ]
        guard let url = uC.url else  {return}
        self.getData(_url: url, completion: completion)
        
    }
    
    func getCoinData(){
        guard let url = self.url else {return}
        self.getData(_url: url)
    }

}
