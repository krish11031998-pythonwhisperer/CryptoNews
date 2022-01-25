//
//  CurrencySummaryView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/10/2021.
//

import SwiftUI


struct CurrencySummaryView: View {
//    var currency:AssetData
    var currency:CrybseCoinMetaData
    var size:CGSize
    
    init(currency:CrybseCoinMetaData,size:CGSize){
        self.currency = currency
        self.size = size
    }
    var values:[String:String]{
        return ["Market Cap":self.currency.marketCap?.ToDecimals() ?? "","Volume 24h":self.currency.dailyVolume?.ToDecimals() ?? "","Rank":String(self.currency.rank ?? 0),"Max Supply":(self.currency.Supply.total ?? 0.0).ToDecimals(),"All Time High": (self.currency.allTimeHigh?.price ?? 0.0).ToMoney(),"Circulating Supply":self.currency.Supply.circulating?.ToDecimals() ?? ""]
    }
    
    var infoKeys:[String]{
        ["Rank","Market Cap","Volume 24h","Max Supply","Circulating Supply","All Time High"]
    }
    
    var col_w:CGFloat{
        return (size.width * 0.5 - 10)
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem.init(.adaptive(minimum: self.col_w, maximum: self.col_w), spacing: 10, alignment: .topLeading)], alignment: .center, spacing: 10) {
            ForEach(self.infoKeys,id: \.self) { key in
                let val = self.values[key] ?? "No Value"
                MainSubHeading(heading: key, subHeading: val, headingSize: 12, subHeadingSize: 15)
            }
        }
    }
}
