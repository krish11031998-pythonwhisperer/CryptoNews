//
//  SwiftUIView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 08/03/2022.
//

import SwiftUI

struct StylisticHeaderView<HeaderView:View,InnerView:View>: View {
    @Environment (\.safeAreaInsets) var safeAreaInset
    var headerView:(CGSize) -> HeaderView
    var innerView:InnerView
    var baseNavBarHeight:CGFloat
    var minimumNavBarHeight:CGFloat
    var onClose:(() -> Void)?
    var bg:AnyView
    var heading:String
    var subHeading:String
    @State var offset:CGFloat
    var customNavbarView:((CGSize) -> AnyView)?
    
    init(
        heading:String = "Title",
        subHeading:String = "SubTitle",
        baseNavBarHeight:CGFloat = totalHeight * 0.4,
        minimumNavBarHeight:CGFloat = totalHeight * 0.15,
        bg:AnyView = Color.AppBGColor.anyViewWrapper(),
        onClose:(() -> Void)? = nil,
        @ViewBuilder headerView:@escaping (CGSize) -> HeaderView,
        @ViewBuilder innerView:@escaping () -> InnerView
    ){
        self.heading = heading
        self.subHeading = subHeading
        self.headerView = headerView
        self.baseNavBarHeight = baseNavBarHeight
        self.minimumNavBarHeight = minimumNavBarHeight
        self.onClose = onClose
        self.bg = bg
        self._offset = .init(initialValue: baseNavBarHeight)
        self.innerView = innerView()
        self.customNavbarView = nil
    }
    
    init(
        baseNavBarHeight:CGFloat = totalHeight * 0.4,
        minimumNavBarHeight:CGFloat = totalHeight * 0.15,
        bg:AnyView = Color.AppBGColor.anyViewWrapper(),
        onClose:(() -> Void)? = nil,
        @ViewBuilder headerView:@escaping (CGSize) -> HeaderView,
        @ViewBuilder innerView:@escaping () -> InnerView,
        customNavBarView:((CGSize) -> AnyView)?
    ){
        self.heading = ""
        self.subHeading = ""
        self.headerView = headerView
        self._offset = .init(initialValue: baseNavBarHeight)
        self.baseNavBarHeight = baseNavBarHeight
        self.minimumNavBarHeight = minimumNavBarHeight
        self.onClose = onClose
        self.bg = bg
        self.innerView = innerView()
        self.customNavbarView = customNavBarView
    }
    
    var mainHeaderViewHeight:CGFloat{
        return self.baseNavBarHeight - self.minimumNavBarHeight
    }
        
    var largeHeaderView:some View{
        let height = (self.offset < self.minimumNavBarHeight ? self.minimumNavBarHeight : self.offset >= self.baseNavBarHeight ? self.baseNavBarHeight : self.offset)
        let mainHeaderHeight = self.offset - self.minimumNavBarHeight > 0 ? self.offset - self.minimumNavBarHeight : 0
        let scaleFactor = abs(mainHeaderHeight)/(self.mainHeaderViewHeight)
        let scale = scaleFactor > 1 ? 1 : scaleFactor < 0 ? 0 : scaleFactor
        let opacity = scale

        
        return Container(width:totalWidth){ inner_w in
            Spacer().frame(height: self.safeAreaInset.top - 15, alignment: .center)
            ZStack(alignment: .top) {
                self.navBarView(width:inner_w,scale:scale)
                self.headerViewBuilder(w: inner_w, h: height - 30, scale: scale, opacity: opacity)
                self.backButton
                    .frame(width: inner_w, alignment: .leading)
                    .scaleEffect(scale)
            }.frame(width: inner_w, height: height, alignment: .center)
        }.frame(width: totalWidth, height: height + self.safeAreaInset.top, alignment: .center)
            .basicCard(background: Color.AppBGColor.anyViewWrapper())
        
 
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            self.bg
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: self.baseNavBarHeight + self.safeAreaInset.top, alignment: .center)
                    .offsetReader(offset: $offset)
                self.innerView
            }
            
            self.largeHeaderView
                .borderCard()
                
        }
        .ignoresSafeArea()

    }
}

extension StylisticHeaderView{
    func navBarView(width:CGFloat,scale:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            if let safeCustomNavBarView = self.customNavbarView{
                if self.onClose != nil{
                    self.backButton
                        .scaleEffect(1 - scale)
                        .opacity(1 - scale)
                }
                
                safeCustomNavBarView(.init(width: self.onClose == nil ? width : width - 50, height: self.minimumNavBarHeight - 20))
                    .scaleEffect(1 - scale)
                    .opacity(1 - scale)
            }else{
                self.backButton
                    .scaleEffect(1 - scale)
                    .opacity(1 - scale)
                Spacer()
                MainTextSubHeading(heading: self.heading, subHeading: self.subHeading, headingSize: 20, subHeadingSize: 13, headColor: .white, subHeadColor: .white, orientation: .vertical, headingWeight: .medium, bodyWeight: .semibold, spacing: 5, alignment: .center)
                    .scaleEffect(1 - scale)
                    .opacity(1 - scale)
                Spacer()
                self.backButton.opacity(0)
            }
        }
        .padding(.vertical,10)
        .frame(width:width,height: self.minimumNavBarHeight * (1 - scale), alignment: .bottomLeading)
    }
    
    @ViewBuilder var backButton:some View{
        if let safeCloseButton = self.onClose{
            SystemButton(b_name: "chevron.left", color: .black, haveBG: true) {
                print("Back Pressed")
                safeCloseButton()
            }
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }

    
    func headerViewBuilder(w:CGFloat,h height:CGFloat,scale:CGFloat,opacity:CGFloat) -> some View{
        Container(width:w,ignoreSides: true,verticalPadding: 0,spacing: 0){ _ in
            if self.onClose != nil{
                self.backButton
                    .opacity(0)
                    .hidden()
                    .frame(width: w,height:35, alignment: .leading)
                self.headerView(.init(width: w, height: height - 35))
                    .frame(width: w, height: height - 35, alignment: .center)
            }else{
                self.headerView(.init(width: w, height: height))
                    .frame(width: w, height: height, alignment: .center)
            }
            
        }
        .frame(width: w, height: height, alignment: .center)
        .scaleEffect(scale)
        .opacity(opacity)
        .animation(.easeInOut, value: height)
    }

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        StylisticHeaderView (onClose: {print("On Close Called")}){ size in
            Color.red
                .frame(width: size.width, height: size.height, alignment: .center)
//                .anyViewWrapper()
        } innerView: {
            Container(heading: "Range Rover Evoque", headingColor: .white, headingDivider: true, width: totalWidth,verticalPadding: 50,orientation: .vertical, aligment: .topLeading, lazyLoad: true) { w in
                MainText(content: "This is a car", fontSize: 15, color: .white, fontWeight: .medium)
            }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
        }
    customNavBarView: { size in
            Color.blue
                .frame(width: size.width, height: size.height, alignment: .center)
                .anyViewWrapper()
        }
    }
}
