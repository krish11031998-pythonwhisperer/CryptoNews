//
//  CrybseSocialAPI.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 30/01/2022.
//

import Foundation

//MARK: - CrybseCoinDataAPI
class CrybseCoinSocialAPI:CrybseCoinAPI{
    
    @Published var coinData:CrybseCoinSocialData? = nil
//    init(crypto:String,coinUID:String,fiat:String,name:String){
    init(coinUID:String,crypto:String,name:String){
        super.init(type: .coinData, params: ["coinUID":coinUID,"crypto":crypto,"cryptoName":name])
    }
    
    override func parseData(url: URL, data: Data) {
        if let safeCoinData = CrybseCoinSocialData.parseCoinDataFromData(data: data){
            setWithAnimation {
                self.coinData = safeCoinData
            }
        }
    }
    
    func getCoinData(){
        guard let safeRequest = self.request else {return}
        self.getData(request: safeRequest)
    }

}
