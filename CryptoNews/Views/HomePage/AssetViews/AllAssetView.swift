//
//  AllAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI

struct AllAssetView: View {
    
//    @StateObject var coinRankAPI:CoinRankCoinsAPI
    @StateObject var crybseAssetsAPI:CrybseAssetsAPI
    @EnvironmentObject var context:ContextData

    
    init(uid:String,currencies:[String]){
        self._crybseAssetsAPI = .init(wrappedValue: .init(symbols: currencies, uid: uid))
    }
    
    func onAppear(){
        
        if self.crybseAssetsAPI.coinsData == nil{
            self.crybseAssetsAPI.getAssets()
        }
        
    }

    func coins(type:String) -> [CrybseAsset]{
        if type == "tracked"{
            return self.crybseAssetsAPI.coinsData?.tracked ?? []
        }else{
            return self.crybseAssetsAPI.coinsData?.watching ?? []
        }
        
    }
    
    func portfolioCardViews(w:CGFloat) -> [AnyView]{
        return self.coins(type: "tracked").sorted(by: {$0.Rank < $1.Rank}).compactMap({AnyView(PortfolioCard(asset: $0, w: w * 0.65))})
    }
    
    var portfolioViews:some View{
        Container(heading: "Portfolio", headingColor: .white,ignoreSides: true) { inner_w in
            CardSlidingView(cardSize: .init(width: inner_w * 0.65, height: totalHeight * 0.45), views: self.portfolioCardViews(w: inner_w),leading: true,centralize: true)
        }
    }


    @ViewBuilder var mainBody:some View{
        self.portfolioViews
        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins(type: "watching"), alternative: false)
    }
    
    var body: some View {
        self.mainBody
        .onAppear(perform: self.onAppear)
    }
}

