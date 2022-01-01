//
//  CurrencySummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/10/2021.
//

import SwiftUI


struct CurrencySummaryView: View {
//    var currency:AssetData
    var currency:CrybseCoin
    var size:CGSize
    
    init(currency:CrybseCoin,size:CGSize){
        self.currency = currency
        self.size = size
    }
    var values:[String:String]{
        return ["Market Cap":"\(self.currency.marketCap)","Volume 24h":self.currency._24hVolume?.ToDecimals() ?? "","Rank" :
                    String(self.currency.rank ?? 0),"Max Supply":self.currency.Supply.total ?? "0","All Time High": Float(self.currency.allTimeHigh?.price ?? "")?.ToMoney() ?? ""]
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
