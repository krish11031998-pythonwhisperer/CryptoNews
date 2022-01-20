//
//  AllAssetView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI
import Combine

struct AllAssetView: View {
    @EnvironmentObject var context:ContextData
    @StateObject var assetAPI:CrybseAssetsAPI = .init(symbols: nil, uid: nil)
    var timer = Timer.TimerPublisher(interval: 30, runLoop: .main, mode: .common).autoconnect()
    
    func onAppear(){
        guard let uid = self.context.user.user?.uid , let currencies = self.context.user.user?.watching, self.assetAPI.coinsData == nil else {return}
        self.assetAPI.uid = uid
        self.assetAPI.symbols = currencies
        self.assetAPI.getAssets()
        
    }
    
    func coins(type:String) -> [CrybseAsset]?{
        if type == "tracked"{
            return self.assetAPI.coinsData?.trackedAssets ?? []
        }else{
            return self.assetAPI.coinsData?.watchingAssets ?? []
        }
        
    }
    
    func updateAssetPrices(){
        CrybsePriceAPI.shared.getMultiplePrice(curr: self.assetAPI.symbols) { assetPriceValue in
            guard let safeAssetPrice = assetPriceValue else {return}
            for (currency,timePrice) in safeAssetPrice{
                if let _ = self.assetAPI.coinsData?.assets?[currency],let latestPrice = timePrice.last?.close{
                    self.assetAPI.coinsData?.assets?[currency]?.Price = latestPrice
                }
            }
        }
    }
    
    func portfolioCardViews(w:CGFloat) -> [AnyView]{
        return self.coins(type: "tracked")?.sorted(by: {$0.Rank < $1.Rank}).compactMap({AnyView(PortfolioCard(asset:$0, w: w * 0.65))}) ?? []
    }
    
    var portfolioViews:some View{
        Container(heading: "Portfolio", headingColor: .white,ignoreSides: true) { inner_w in
            CardSlidingView(cardSize: .init(width: inner_w * 0.65, height: totalHeight * 0.45), views: self.portfolioCardViews(w: inner_w),leading: true,centralize: true)
        }
    }


    @ViewBuilder var mainBody:some View{
        self.portfolioViews
        AssetViewBuilder(type: "watching", size:CardSize.medium, coins: self.coins(type: "watching") ?? [], alternative: false)
    }
    
    var body: some View {
        self.mainBody
            .onAppear(perform: self.onAppear)
            .onReceive(self.timer) { _ in
                self.updateAssetPrices()
            }
    }
}

