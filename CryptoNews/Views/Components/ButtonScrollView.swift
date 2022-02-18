//
//  ButtonScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 26/01/2022.
//

import Foundation
import SwiftUI

struct ButtonScrollView:View{
    enum Direction{
        case left
        case right
        case none
    }
    
    var headerviews:[String:AnyView]
    var width:CGFloat
    @StateObject var SP:swipeParams
    @State var direction:Direction = .none
    @State var selectedTabName:String
    init(headerviews:[String:AnyView],width:CGFloat = totalWidth){
        self.headerviews = headerviews
        self._selectedTabName = .init(wrappedValue: headerviews.keys.sorted().first ?? "")
        self.width = width
        self._SP = .init(wrappedValue: .init(0, headerviews.count, singleSide: true))
    }
        
    var headers:[String]{
        return Array(self.headerviews.keys).sorted()
    }
    
    var selectedTab:Int{
        get{
            return self.SP.swiped
        }
    }

    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * (self.width + 25)
    }
    
    func tabBarHeader() -> some View {
        HStack(spacing:20){
            ForEach(Array(self.headers.enumerated()),id:\.offset){ _header in
                let header = _header.element
                let idx = _header.offset
                
                let bgColor:AnyView = self.selectedTabName != header ? AnyView(Color.clear) : AnyView(mainBGView)
                MainText(content: header, fontSize: 15, color: .white, fontWeight: .semibold)
                    .padding(.horizontal,7.5)
                    .blobify(color: bgColor,clipping: .roundClipping)
                    .buttonify {
                        setWithAnimation(animation:Animation.easeInOut(duration: 0.4)){
                            if self.SP.swiped != idx{
                                self.direction = self.SP.swiped < idx ? .right : .left
                                self.SP.swiped = idx
                                
                            }
                            if self.selectedTabName != header{
                                self.selectedTabName = header
                            }
                        }
                    }
            }
        }.frame(width: self.width, alignment: .leading)
    }
    
    var innerMainView:some View{
        HStack(alignment:.top,spacing:25){
            ForEach(Array(self.headers.enumerated()), id:\.offset) { _header in
                let header = _header.element
                
                if let view = self.headerviews[header]{
                    view
                        .frame(width:self.width)
                }
            }
        }
        .frame(width:self.width,alignment: .leading)
        .offset(x: self.offset)
    }
    

    var transition:AnyTransition{
        return self.direction == .right ? .slideRightLeft : self.direction == .left ? .slideLeftRight : .slide
    }
    
    var transitionTabView:some View{
        VStack(alignment: .center, spacing: 10) {
            self.tabBarHeader()
            ForEach(self.headers, id:\.self) { header in
                if let view = self.headerviews[header], self.selectedTabName == header{
                    view
                        .padding(.top,10)
                        .frame(width: self.width, alignment: .center)
                        .slideRightLeft()
                    
                }
            }
        }
    }
    
    var body: some View{
        self.tabBarHeader()
        self.innerMainView
    }
}


struct ButtonScrollViewPreview:PreviewProvider{
    
    static var previews: some View{
        ZStack {
            mainBGView
            Container (width:totalWidth,ignoreSides: false){ w in
                ButtonScrollView(headerviews: ["Red":AnyView(Color.red.frame(height: totalHeight * 0.25, alignment: .topLeading).clipContent(clipping: .roundClipping)),"Blue":AnyView(Color.blue.frame(height: totalHeight * 0.5, alignment: .topLeading).clipContent(clipping: .roundClipping)),"Gray":AnyView(Color.gray.frame(height: totalHeight * 0.5, alignment: .topLeading).clipContent(clipping: .roundClipping))], width: w)
            }.padding(.vertical,50).frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
            
        }.ignoresSafeArea()
        
    }
}
