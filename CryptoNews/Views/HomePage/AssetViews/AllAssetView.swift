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
    var timer = Timer.TimerPublisher(interval: 150, runLoop: .main, mode: .common).autoconnect()
        
    var assets:CrybseAssets{
        return self.context.userAssets
    }
    
    func coins(type:String) -> [CrybseAsset]?{
        if type == "tracked"{
            return self.assets.trackedAssets
        }else{
            return self.assets.watchingAssets
        }
        
    }
    
    func updateAssetPrices(){
        print("(DEBUG) Currencies : ",self.context.Currencies)
        if self.context.Currencies.count  > 0{
            CrybseMultiCoinPriceAPI.shared.getPrices(coins: self.context.Currencies) { prices in
                for (currency,price) in prices{
                    self.context.userAssets.assets?[currency]?.Price = price.USD
                }
            }
        }
    }
    
    func portfolioCardViews(w:CGFloat) -> [AnyView]{
        return self.coins(type: "tracked")?.sorted(by: {$0.Rank < $1.Rank}).compactMap({AnyView(PortfolioCard(asset:$0, w: w * 0.65,h:totalHeight * 0.65))}) ?? []
    }
    
    var portfolioViews:some View{
        Container(heading: "Portfolio", headingColor: .white,ignoreSides: true) { inner_w in
            ScrollZoomInOutView(cardSize: .init(width: inner_w * 0.5, height: totalHeight * 0.45), views: self.portfolioCardViews(w: inner_w),leading: true,centralize: true)
        }
    }

    func watchListCardSize(_ inner_w:CGFloat) -> CGSize{
        return .init(width: inner_w * 0.5, height: totalHeight * 0.3)
    }
    
    func watchListViews(size:CGSize) -> [AnyView]{
        return (self.coins(type: "watching") ?? []).compactMap({AnyView(PriceCard(coin: $0, size: size))})
    }

    @ViewBuilder var mainBody:some View{
        Container(width: totalWidth) { w in
            PortfolioSummary(width: w,height: totalHeight * 0.2)
                .borderCard(color: .white, clipping: .roundClipping)
            QuickWatch(assets: self.context.userAssets.watchingAssets, width: w)
        }
    }
    
    var body: some View {
        self.mainBody
            .onReceive(self.timer) { _ in
                self.context.userAssets.updateAssetPrices()
            }
    }
}

