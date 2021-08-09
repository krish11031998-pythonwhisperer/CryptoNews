//
//  HomePage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 07/08/2021.
//

import SwiftUI

struct HomePage: View {
    var currencies:[String] = ["BTC","LTC"]
    var color:[String:Color] = ["BTC":Color.orange,"LTC":Color.yellow]
//    var currencies:[String] = ["BTC"]
//
    var body: some View {
        ScrollView(.vertical,showsIndicators:false){
            ScrollView(.horizontal, showsIndicators: false){
                HStack(alignment: .center, spacing: 10){
                    ForEach(self.currencies,id:\.self) { currency in
                        PriceCard(currency: currency,color: self.color[currency] ?? .white)
                    }
                }.padding()
            }.padding(.top,50)
//            ForEach(self.currencies,id:\.self) { currency in
//                RecentNews(currency: currency)
//            }
            RecentNewsCarousel()
        }
        .frame(width: totalWidth, alignment: .center)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
