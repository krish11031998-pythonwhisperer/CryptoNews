//
//  CurrencyFeed.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 09/12/2021.
//

import SwiftUI

struct CurrencyFeed: View {
    @EnvironmentObject var context:ContextData
    @State var currencyIdx:Int = 1
    
    var body: some View {
        Container(heading: "Latest Feed", width: totalWidth, ignoreSides: true) { _ in
            NewsSectionMain(currencies: self.currencies,limit: 15).padding(.vertical,10)
        }
    }
}

extension CurrencyFeed{
    
    var currencies:[String]{
        return self.context.user.user?.watching ?? ["MANA","XRP","LTC","BTC"]
    }
}

struct CurrencyFeed_Previews: PreviewProvider {
    
    static var context:ContextData = .init()
    
    static var previews: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CurrencyFeed()
                .environmentObject(CurrencyFeed_Previews.context)
        }.background(Color.mainBGColor)
            .ignoresSafeArea()
    }
}
