//
//  CustomNavigationLinkedView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 07/03/2022.
//

import SwiftUI

struct TitleSubTitle:Equatable{
    var title:String?
    var subTitle:String?
}

struct TitleSubTitlePreferenceKey:PreferenceKey{
    static var defaultValue: TitleSubTitle = TitleSubTitle()
    
    static func reduce(value: inout TitleSubTitle, nextValue: () -> TitleSubTitle) {
        value = nextValue()
    }
}

struct CustomNavBarContainerView<Content:View>: View {
    @Environment(\.presentationMode) var presentationMode
    var content:Content
    @State var title:String?
    @State var subTitle:String?
    @State var offset:CGFloat = 0.0
    var fontColor:Color
    var rightButton:(() -> AnyView)?
    var mainHeaderView: ((CGSize) -> AnyView)?
    
    init(title:String? = nil,subTitle:String? = nil,fontColor:Color = .black,@ViewBuilder content : @escaping () -> Content,mainHeaderView: ((CGSize) -> AnyView)? = nil,rightButton: (() -> AnyView)? = nil){
        self._title = .init(initialValue: title)
        self._subTitle = .init(initialValue: subTitle)
        self.content = content()
        self.fontColor = fontColor
        self.rightButton = rightButton
        self.mainHeaderView = mainHeaderView
    }
    
    var customNavigationBar:some View{
        self.navBarView(showTitle: true)
        .padding(.horizontal,5)
        .padding(.vertical,15)
        .padding(.top,35)
        .frame(width: totalWidth, alignment: .center)
        .background(Color.AppBGColor)
    }
    
    var baseNavBarHeight:CGFloat{
        return totalHeight * 0.4
    }
    
    
    var mainHeaderViewHeight:CGFloat{
        return self.baseNavBarHeight * 0.75
    }
    
    var minimumNavBarHeight:CGFloat{
        return self.baseNavBarHeight * 0.25
    }
    
    var largeHeaderView:some View{
        let height = self.offset < self.minimumNavBarHeight ? self.minimumNavBarHeight : self.offset
        let mainHeaderHeight = self.offset - self.minimumNavBarHeight - 30 > 0 ? self.offset - self.minimumNavBarHeight - 30 : 0
        let scaleFactor = abs(mainHeaderHeight)/(self.mainHeaderViewHeight - 30)
        let scale = scaleFactor > 1 ? 1 : scaleFactor < 0 ? 0 : scaleFactor
        let opacity = scale
        return Container(width: totalWidth,verticalPadding: 15,spacing: 0) { inner_w in
            self.navBarView(showTitle: false)
            if let mainHeaderView = self.mainHeaderView{
                mainHeaderView(.init(width: inner_w, height: self.mainHeaderViewHeight - 30))
                    .frame(height: mainHeaderHeight, alignment: .center)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.easeInOut, value: height)
            }else{
                self.titleView
                    .animation(.easeOut, value: height)
            }
        }
        .frame(width: totalWidth,height: height, alignment: .center)
        .background(Color.AppBGColor)
        .clipContent(clipping: .roundCornerMedium)
    }
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                Spacer().frame(height: self.baseNavBarHeight, alignment: .center)
                    .offsetReader(offset: $offset)
                Container(width:totalWidth,ignoreSides: true,verticalPadding: 0,spacing: 0,lazyLoad: true) { _ in
                    self.content
                }
            }
            
            self.largeHeaderView
                
        }
        .ignoresSafeArea()
        .onPreferenceChange(TitleSubTitlePreferenceKey.self) { titlesubTitle in
            DispatchQueue.main.async {
                self.title = titlesubTitle.title
                self.subTitle = titlesubTitle.subTitle
            }
        }
        
        
    }
}

extension CustomNavBarContainerView{
    var backButton:some View{
        SystemButton(b_name: "chevron.left", color: .black, haveBG: true) {
            print("Back Pressed")
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @ViewBuilder var rightSideView:some View{
        if let rightButton = rightButton {
            rightButton()
        }else{
            self.backButton.opacity(0)
        }
    }
    
    @ViewBuilder var titleView:some View{
        if let title = title, self.subTitle == nil {
            MainText(content: title, fontSize: 20, color: self.fontColor, fontWeight: .medium, padding: 15)
        }else if let title = self.title, let subTitle = self.subTitle{
            MainSubHeading(heading: title, subHeading: subTitle, headingSize: 25, subHeadingSize: 15, headColor: self.fontColor, subHeadColor: self.fontColor, orientation: .vertical, headingWeight: .medium, bodyWeight: .regular, spacing: 10, alignment: .center)
        }
    }
    
    func navBarView(showTitle:Bool) -> some View{
        HStack(alignment: .center, spacing: 10) {
            self.backButton
            Spacer()
            if showTitle{
                self.titleView
                Spacer()
            }
            self.rightSideView
        }.frame(height: self.minimumNavBarHeight, alignment: .center)
    }
}

public extension View{

    func customNavigationTitleAndSubTitle(_ title:String? = nil,_ subTitle:String? = nil) -> some View{
        self.preference(key: TitleSubTitlePreferenceKey.self, value: .init(title: title,subTitle: subTitle))
    }
    
    @ViewBuilder func customNavBarContainerView(mainHeaderView:((CGSize) -> AnyView)? = nil, rightSidebarView:(() -> AnyView)? = nil) -> some View{
        if mainHeaderView == nil && rightSidebarView == nil{
            CustomNavBarContainerView {
                self.navigationBarHidden(true)
            }
        }else if let mainHeaderView = mainHeaderView,rightSidebarView == nil {
            CustomNavBarContainerView {
                self.navigationBarHidden(true)
            } mainHeaderView: { size in
                mainHeaderView(size)
            }
        }else if let rightSidebarView = rightSidebarView, mainHeaderView == nil{
            CustomNavBarContainerView {
                self.navigationBarHidden(true)
            } rightButton: {
                rightSidebarView()
            }
        }else if let mainHeaderView = mainHeaderView, let rightSideView = rightSidebarView {
            CustomNavBarContainerView {
                self.navigationBarHidden(true)
            } mainHeaderView: { size in
                mainHeaderView(size)
            } rightButton: {
                rightSideView()
            }
        }
    }
    
}

struct CustomNavigationLinkedView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBarContainerView(title: "Title", subTitle: "SubTitle", fontColor: .black){
            Color.red.frame(width: totalWidth, height: totalHeight, alignment: .center)
            Color.blue.frame(width: totalWidth, height: totalHeight, alignment: .center)
        } mainHeaderView: { size in
            SceneKitView(model_name: "American_Muscle_71_-_Low_poly_model", size: size, allowControl: true).clipContent(clipping: .roundClipping).anyViewWrapper()
            
        }
    }
}
