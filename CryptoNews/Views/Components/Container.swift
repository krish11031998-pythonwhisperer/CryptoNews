//
//  Container.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/08/2021.
//

import SwiftUI

struct Container: View {
    var innerView:(CGFloat) -> AnyView
    var heading:String
    init(heading:String,innerView:@escaping (CGFloat) -> AnyView){
        self.heading = heading
        self.innerView = innerView
    }
    
    var body: some View {
        let w = totalWidth - 30
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: self.heading, fontSize: 30, color: .black, fontWeight: .semibold)
            Divider().frame(width:w * 0.5,alignment: .leading)
                .padding(.bottom,10)
            self.innerView(w)
        }
        .padding(.horizontal,15)
        .padding(.vertical,10)
        .frame(width: totalWidth, alignment: .leading)
    }
}
