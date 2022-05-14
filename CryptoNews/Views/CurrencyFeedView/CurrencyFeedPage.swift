//
//  FeedPage.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

enum FeedPageType{
    case news
//    case feed
    case reddit
    case twitter
}


struct CurrencyFeedPage<T:View>: View {
    var symbol:String
    var data:[Any]
    var viewBuilder: (Any,CGFloat) -> T
    var reload: () -> Void
    var type:FeedPageType
    var width:CGFloat
    
    init(w:CGFloat,symbol:String,data:[Any],type:FeedPageType,@ViewBuilder viewBuilder: @escaping (Any,CGFloat) -> T,reload: @escaping () -> Void){
        self.symbol = symbol
        self.type = type
        self.viewBuilder = viewBuilder
        self.data = data
        self.width = w
        self.reload = reload
    }
    
    
    var body: some View {
        
        if !self.data.isEmpty{
            LazyScrollView(data: self.data.map({$0 as Any}),embedScrollView: false) { data in
                self.viewBuilder(data,self.width)
            }.onPreferenceChange(RefreshPreference.self) { reload in
                if reload{
                    self.reload()
                }
            }
        }else{
            ProgressView()
                .padding(.bottom,50)
        }
        
    }
}

