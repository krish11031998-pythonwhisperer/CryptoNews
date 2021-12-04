//
//  CurrencySummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/10/2021.
//

import SwiftUI


struct CurrencySummaryView: View {
    var currency:AssetData
    var size:CGSize
    
    init(currency:AssetData,size:CGSize){
        self.currency = currency
        self.size = size
    }
    var values:[String:String]{
        let market_dom = convertToDecimals(value: self.currency.market_dominance)
        return ["Market Cap":convertToMoneyNumber(value: self.currency.market_cap),"Volume 24h":convertToDecimals(value: self.currency.volume_24h),"Rank" :
                    String(self.currency.market_cap_rank ?? 0),"Max Supply":self.currency.max_supply ?? "0","Market Dominance": "\(market_dom)%","Volume":convertToDecimals(value: self.currency.volume)]
    }
    
    var col_w:CGFloat{
        return (size.width * 0.5 - 10)
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem.init(.adaptive(minimum: self.col_w, maximum: self.col_w), spacing: 10, alignment: .topLeading)], alignment: .center, spacing: 10) {
            ForEach(Array(self.values.keys),id: \.self) { key in
                let val = self.values[key] ?? "No Value"
                MainSubHeading(heading: key, subHeading: val, headingSize: 12, subHeadingSize: 15)
            }
        }.padding(.top,20)
    }
}
