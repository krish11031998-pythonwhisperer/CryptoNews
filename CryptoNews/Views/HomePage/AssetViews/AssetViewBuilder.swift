//
//  AssetViewBuilder.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 21/12/2021.
//

import SwiftUI

struct AssetViewBuilder: View {
    var type:String
    var alternative:Bool
    var coins:[CoinData]
    var size:CGSize
    
    init(type:String,size:CGSize = CardSize.normal,coins:[CoinData],alternative:Bool){
        self.type = type
        self.coins = coins
        self.alternative = alternative
        self.size = size
    }
    
    
    var heading:String{
        self.type == "tracked" ? "Tracked Assets" : "Watched Assets"
    }
    
    var views:[AnyView]{
        self.coins.compactMap({AnyView(PriceCard(coin: $0,size: self.size,alternativeView: self.alternative))})
    }

    var body: some View {
        Container(heading: heading, width: totalWidth, ignoreSides: true) { w in
            if self.coins.isEmpty{
                ProgressView()
            }else{
                CardSlidingView(cardSize: self.size, views: views, leading: false)
            }
        }
    }
}

