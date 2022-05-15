//
//  SwiftUIView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 08/03/2022.
//

import SwiftUI

struct StylisticHeaderView<HeaderView:View,InnerView:View>: View {
    
    var headerView:(CGSize) -> HeaderView
    var innerView:InnerView
    var baseNavBarHeight:CGFloat
    var minimumNavBarHeight:CGFloat
    var onClose:(() -> Void)?
    var bg:AnyView
    var heading:String
    var subHeading:String
    @State var offset:CGFloat = .zero
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
        self.innerView = innerView()
        self.customNavbarView = nil
    }
    
    var mainHeaderViewHeight:CGFloat{
        return self.baseNavBarHeight - self.minimumNavBarHeight
    }
        
    var largeHeaderView:some View{
        let height = (self.offset < self.minimumNavBarHeight ? self.minimumNavBarHeight : self.offset >= self.baseNavBarHeight ? self.baseNavBarHeight : self.offset) - 30
        let mainHeaderHeight = self.offset - self.minimumNavBarHeight > 0 ? self.offset - self.minimumNavBarHeight : 0
        let scaleFactor = abs(mainHeaderHeight)/(self.mainHeaderViewHeight - 30)
        let scale = scaleFactor > 1 ? 1 : scaleFactor < 0 ? 0 : scaleFactor
        let opacity = scale
        
        return Container(width: totalWidth,verticalPadding: 15,spacing: 0) { inner_w in
            self.navBarView(scale:scale,showTitle: false)
            self.headerView(.init(width: inner_w, height: self.mainHeaderViewHeight - 30))
                .frame(height: mainHeaderHeight, alignment: .center)
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(.easeInOut, value: height)
        }
        .frame(width: totalWidth,height: height + 30, alignment: .center)
        .background(Color.AppBGColor)
        .clipContent(clipping: .roundCornerMedium)
 
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            self.bg
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: self.baseNavBarHeight, alignment: .center)
                    .offsetReader(offset: $offset)
                self.innerView.offset(y: -20)
            }
            
            self.largeHeaderView
                
        }
        .ignoresSafeArea()

    }
}

extension StylisticHeaderView{
    func navBarView(scale:CGFloat,showTitle:Bool) -> some View{
        HStack(alignment: .center, spacing: 10) {
            self.backButton
            Spacer()
            MainTextSubHeading(heading: self.heading, subHeading: self.subHeading, headingSize: 20, subHeadingSize: 13, headColor: .white, subHeadColor: .white, orientation: .vertical, headingWeight: .medium, bodyWeight: .semibold, spacing: 5, alignment: .center)
                .scaleEffect(1 - scale)
                .opacity(1 - scale)
            Spacer()
            self.backButton.opacity(0)
        }
        .padding(.bottom,10)
        .frame(height: self.minimumNavBarHeight * (self.onClose == nil ? (1 - scale) : 1), alignment: .bottomLeading)
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


}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        StylisticHeaderView (onClose: {print("On Close Called")}){ size in
            Color.red
                .anyViewWrapper()
        } innerView: {
            Container(heading: "Range Rover Evoque", headingColor: .white, headingDivider: true, width: totalWidth,verticalPadding: 50,orientation: .vertical, aligment: .topLeading, lazyLoad: true) { w in
                MainText(content: "This is a car", fontSize: 15, color: .white, fontWeight: .medium)
            }.frame(width: totalWidth, height: totalHeight, alignment: .topLeading)
        }
    }
}
