//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    var currencies:[String] = ["BTC","LTC","ETH"]
    var color:[String:Color] = ["BTC":Color.orange,"LTC":Color.yellow,"ETH":Color.blue]
//    var currencies:[String] = ["BTC"]
//
    var body: some View {
        ScrollView(.vertical,showsIndicators:false){
            VStack(alignment: .center, spacing: 15) {
                Spacer().frame(height: 50)
                self.PriceCards
                self.NewsSection
//                LatestTweets(currency: "all")
                LatestTweets(currency: "all")
//                LatestRedditView(currency: "all")
                CryptoMarket()
//
//                InfluentialTweets()
                Spacer(minLength: 200)
            }
        }
        .frame(width: totalWidth, alignment: .center)
        .background(Color.black.opacity(0.1).overlay(BlurView(style: .light)))
        .edgesIgnoringSafeArea(.all)
    }
}

extension HomePage{
    var PriceCards:some View{
        ScrollView(.horizontal, showsIndicators: false){
            LazyHStack(alignment: .center, spacing: 10){
                ForEach(self.currencies,id:\.self) { currency in
                    PriceCard(currency: currency,color: self.color[currency] ?? .white,font_color: .white)
                }
            }.padding()
        }
    }
    
    
    var NewsSection:some View{
        return RecentNewsCarousel(heading: "News") { currency in
            guard let curr = currency as? String  else {return AnyView(Color.clear)}
            return AnyView(RecentNews(currency: curr,ext_h: true))
        }
        
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
