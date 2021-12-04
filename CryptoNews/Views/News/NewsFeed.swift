//
//  NewsFeed.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 19/11/2021.
//

import SwiftUI

struct NewsFeed: View {
    @EnvironmentObject var context:ContextData
    @State var size:CGSize = .zero
    var currencies:[String]{
        print(self.context.user.user?.watching)
        return self.context.user.user?.watching ?? ["BTC","LTC","ETH","XRP"]
    }
    
    var body: some View {
        Group{
            ForEach(self.currencies,id:\.self) {currency in
                AsyncContainer(size: self.size) {
                    //                    Container(heading: "\(currency) Latest News", width: totalWidth, ignoreSides: true) { _ in
                    NewsSectionMain(currency: currency).padding(.vertical,10)
                    //                    }
                    
                }.onPreferenceChange(SizeDataPreferenceKey.self){size in
                    if self.size != size{
                        self.size = size
                    }
                }
            }
        }
    }
}

struct NewsFeed_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeed()
    }
}
