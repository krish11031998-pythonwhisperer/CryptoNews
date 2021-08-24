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
    init(heading:String,data:[String] = ["BTC","LTC","ETH","XRP"],view:@escaping (Any) -> AnyView){
        self.heading = heading
        self.data = data
        self.view = view
    }
    
    var body: some View {
        let h = totalHeight * 0.7
        Container(heading: "News") { w  in
            let size = CGSize(width: w, height: h)
            return AnyView(FancyHScroll(views: self.data.map({AnyView(self.view($0))}),headers: self.data as? [String], size: size))
        }
        
    }
    
}
