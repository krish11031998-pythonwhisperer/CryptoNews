//
//  CrybseCoinAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 29/12/2021.
//

import Foundation


class CrybseCoinAPI:DAPI{
    
    @Published var coinData:CrybseCoinData? = nil
    
    var coinUID:String = ""
    var fiat:String = ""
    var crypto:String = ""
    
    init(coinUID:String,fiat:String,crypto:String){
        self.coinUID = coinUID
        self.fiat = fiat
        self.crypto = crypto
    }
    
    
    var url:URL?{
        var uC = URLComponents()
        uC.scheme = "https"
        uC.host = "crybse.herokuapp.com"
        uC.path = "/coinData"
        uC.queryItems = [
            URLQueryItem(name: "coinUID", value: coinUID),
            URLQueryItem(name: "fiat", value: fiat),
            URLQueryItem(name: "crypto", value: crypto)
        ]
        return uC.url
    }
    
    override func parseData(url: URL, data: Data) {
        DataCache.shared[url] = data
        DispatchQueue.main.async {
            if let data = CrybseCoinData.parseCoinDataFromData(data: data){
                self.coinData = data
            }
            
            if self.loading{
                self.loading.toggle()
            }
        }
    }
    
    func getCoinData(){
        guard let url = self.url else {return}
        self.getData(_url: url)
    }

}
