//
//  CryptoMarket.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/08/2021.
//

import SwiftUI

struct CryptoMarket: View {
    @StateObject var MAPI:MarketAPI = .init()
    
    func onAppear(){
        if self.MAPI.data.isEmpty{
            self.MAPI.getMarketData()
        }
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5)
    
    var view:[AnyView]?{
        if !self.MAPI.data.isEmpty{
            return self.MAPI.data.enumerated().compactMap({AnyView(CryptoMarketCard(data: $0.element,size: cardSize, rank: $0.offset + 1))})
        }
        
        return nil
    }
    
    var body: some View {
        Container(heading: "Crypto Market", width: totalWidth) { w in
            ZStack{
                if let views = self.view{
                    CardSlidingView(cardSize: .init(width: cardSize.width, height: cardSize.height),views: views)
                }else{
                    ProgressView()
                }
            }.onAppear(perform: self.onAppear)
        }
    }
}




struct CryptoMarket_Previews: PreviewProvider {
    static var previews: some View {
//        ScrollView(.vertical, showsIndicators: false){
            CryptoMarket()
//        }
    }
}
