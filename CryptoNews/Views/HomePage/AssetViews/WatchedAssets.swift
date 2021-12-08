//
//  WatchedAssets.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/12/2021.
//

import SwiftUI

struct WatchedAssets: View {
    @EnvironmentObject var context:ContextData
    var currencies:[String]
    
    var cardSize:CGSize{
        return CardSize.medium
    }
    
    
    var views:[AnyView]{
        return self.currencies.map({AnyView(PriceCard(currency: $0,size: cardSize, alternativeView: true))})
    }
    
    var body: some View {
        Container(heading: "Watched Assets", width: totalWidth, ignoreSides: true) { _ in
            CardSlidingView(cardSize: cardSize, views: self.views, leading: false)
        }
    }
}

struct WatchedAssets_Previews: PreviewProvider {
    
    static var context:ContextData = .init()
    
    static var previews: some View {
        ZStack(alignment: .center) {
            WatchedAssets(currencies: ["MANA","XRP","BTC"])
                .environmentObject(WatchedAssets_Previews.context)
        }.background(mainBGView)
        .ignoresSafeArea()
        
    }
}
