//
//  ButtonScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/01/2022.
//

import Foundation
import SwiftUI

struct ButtonScrollView:View{
    var headerviews:[String:AnyView]
    var width:CGFloat
    @State var selectedTab:String? = nil
    init(headerviews:[String:AnyView],width:CGFloat = totalWidth){
        self.headerviews = headerviews
        self.width = width
        if let firstTab = headerviews.keys.sorted().first {
            self._selectedTab = .init(initialValue: firstTab)
        }
    }
        
    var headers:[String]{
        return Array(self.headerviews.keys).sorted()
    }
    
    func tabBarHeader(proxy:ScrollViewProxy) -> some View {
        
        LazyHStack(spacing:20){
            ForEach(Array(self.headers.enumerated()),id:\.offset){ _header in
                let header = _header.element
                let color:Color = self.selectedTab == nil || (self.selectedTab != nil && self.selectedTab! != header) ? .white : .white
                let bgColor:AnyView = self.selectedTab == nil || (self.selectedTab != nil && self.selectedTab! != header) ? AnyView(Color.clear) : AnyView(mainBGView)
                MainText(content: header, fontSize: 15, color: color, fontWeight: .semibold)
                    .padding(.horizontal,7.5)
                    .blobify(color: bgColor,clipping: .roundClipping)
                    .buttonify {
                        proxy.scrollTo(header, anchor: .leading)
                        setWithAnimation {
                            if self.selectedTab != header{
                                self.selectedTab = header
                            }
                        }
                    }
            }
        }.frame(width: self.width, alignment: .leading)
    }
    
    var innerMainView:some View{
        HStack(alignment:.top,spacing:20){
            ForEach(Array(self.headers.enumerated()), id:\.offset) { _header in
                let header = _header.element
                
                if let view = self.headerviews[header]{
                    view
                        .frame(width:self.width)
                        .id(header)
                }
            }
        }
    }
    
    var body: some View{
        ScrollViewReader { proxy in
            self.tabBarHeader(proxy: proxy)
            
            ScrollView(.horizontal, showsIndicators: false) {
                self.innerMainView
            }.frame(width: width, alignment: .center)
            
        }
    }
}


struct ButtonScrollViewPreview:PreviewProvider{
    
    static var previews: some View{
        ZStack {
            mainBGView
            ButtonScrollView(headerviews: ["Red":AnyView(Color.red.frame(height: totalHeight * 0.25, alignment: .topLeading).clipContent(clipping: .roundClipping)),"Blue":AnyView(Color.blue.frame(height: totalHeight * 0.5, alignment: .topLeading).clipContent(clipping: .roundClipping))], width: totalWidth - 50)
                .frame(height: totalHeight * 0.5, alignment: .topLeading)
        }.ignoresSafeArea()
        
    }
}
