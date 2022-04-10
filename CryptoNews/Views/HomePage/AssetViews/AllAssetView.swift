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
//    var timer = Timer.TimerPublisher(interval: 150, runLoop: .main, mode: .common).autoconnect()
        
    var assets:CrybseAssets{
        return self.context.userAssets
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

    @ViewBuilder var mainBody:some View{
        Container(width: totalWidth) { w in
            PortfolioSummary(width: w,height: totalHeight * 0.25)
                .borderCard(color: .white, clipping: .roundClipping)
        }
    }
    
    var body: some View {
        self.mainBody
//            .onReceive(self.timer) { _ in
//                self.context.userAssets.updateAssetPrices()
//            }
    }
}

