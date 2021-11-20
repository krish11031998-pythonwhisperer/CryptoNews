//
//  RecentNewsCarousel.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/08/2021.
//

import SwiftUI

struct RecentNewsCarousel: View {
    var heading:String
    var view: (Any) -> AnyView
    var data:[Any]
    var size:CGSize
    init(heading:String,data:[Any] = ["BTC","LTC","ETH","XRP"],view:@escaping (Any) -> AnyView,size:CGSize = .init(width: totalWidth - 20, height: 350)){
        self.heading = heading
        self.data = data
        self.view = view
        self.size = size
    }
    
    var body: some View {
        Container(heading: "News") { w  in
            FancyHScroll(data: self.data,timeLimit: 60, size: size,viewGen: self.view)
        }
        
    }
    
}
