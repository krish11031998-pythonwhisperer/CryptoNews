//
//  HoverView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/10/2021.
//

import Foundation
import SwiftUI


struct HoverView<T:View>:View{
    var heading:String
    var inner_view: (CGFloat) -> T
    var onClose:(() -> Void)?
    init(heading:String="Heading",onClose: (() -> Void)? = nil,inner_view: @escaping (CGFloat) ->T){
        self.heading = heading
        self.inner_view = inner_view
        self.onClose = onClose
    }
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: heading, width: totalWidth,onClose: onClose){ w in
                    self.inner_view(w)
            }
            .padding(.top,50)
        }
        
        .frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
        .background(mainBGView)
        .slideRightLeft()
    }
}
