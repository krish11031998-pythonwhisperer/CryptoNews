//
//  CustomNavLink.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 07/03/2022.
//

import SwiftUI


struct CustomLinkPrefrenceKey:PreferenceKey{
    static var defaultValue: Bool = false
    
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
    
}

struct CustomNavDestinationView<Destination:View>:View{
    var destination:(CGFloat) -> Destination
    var header:String?
    @Binding var isActive:Bool
    var ignoreSide:Bool
    @Environment (\.presentationMode) var presentationMode
    
    init(header:String? = nil,ignoreSide:Bool = false,isActive:Binding<Bool>,@ViewBuilder destinationBuilder: @escaping (CGFloat) -> Destination){
        self._isActive = isActive
        self.destination = destinationBuilder
        self.header = header
        self.ignoreSide = ignoreSide
    }
    
    func onClose(){
        if self.isActive{
            self.isActive.toggle()
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            Container(heading: self.header, headingColor: .white, headingDivider: false, headingSize: 30, width: totalWidth,ignoreSides: self.ignoreSide,horizontalPadding: 7.5, onClose: self.onClose) { w in
                self.destination(w)
            }
        }
    }
    
}

struct CustomNavLinkWithoutLabel<Destination:View>:View{
    var destination:Destination
    var mainHeaderView: ((CGSize) -> AnyView)?
    var rightSidebarView:(() -> AnyView)?
    @Binding var isActive:Bool
    init(isActive:Binding<Bool>,@ViewBuilder destination:@escaping () -> Destination,mainHeaderView: ((CGSize) -> AnyView)? = nil,rightSidebarView:(() -> AnyView)? = nil){
        self._isActive = isActive
        self.destination = destination()
        self.mainHeaderView = mainHeaderView
        self.rightSidebarView = rightSidebarView
    }
    
    
    @ViewBuilder func destinationView() -> some View{
        Group{
            if self.mainHeaderView != nil || self.rightSidebarView != nil {
                self.destination
                .customNavBarContainerView(mainHeaderView: self.mainHeaderView, rightSidebarView: self.rightSidebarView)
            }else{
                self.destination
                .navigationBarHidden(true)
            }
        }
        .background(Color.AppBGColor.ignoresSafeArea())
    }
    
    var body: some View {
        NavigationLink(isActive: self.$isActive,destination: self.destinationView) {
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }
    
}


struct CustomNavLinkWithoutLabelWithInnerView<Destination:View>:View{
    var destination:(CGFloat) -> Destination
    var mainHeaderView: ((CGSize) -> AnyView)?
    var rightSidebarView:(() -> AnyView)?
    var header:String?
    var ignoreSides:Bool
    @Binding var isActive:Bool
    init(header:String? = nil,ignoreSide:Bool = false,isActive:Binding<Bool>,@ViewBuilder destination:@escaping (CGFloat) -> Destination,mainHeaderView: ((CGSize) -> AnyView)? = nil,rightSidebarView:(() -> AnyView)? = nil){
        self._isActive = isActive
        self.destination = destination
        self.mainHeaderView = mainHeaderView
        self.rightSidebarView = rightSidebarView
        self.header = header
        self.ignoreSides = ignoreSide
    }
    
    
    @ViewBuilder func destinationView() -> some View{
        Group{
            if self.mainHeaderView != nil || self.rightSidebarView != nil {
                CustomNavDestinationView(header: self.header,ignoreSide: self.ignoreSides, isActive: self.$isActive, destinationBuilder: self.destination)
                .customNavBarContainerView(mainHeaderView: self.mainHeaderView, rightSidebarView: self.rightSidebarView)
            }else{
                CustomNavDestinationView(header: self.header,ignoreSide: self.ignoreSides, isActive: self.$isActive, destinationBuilder: self.destination)
                .navigationBarHidden(true)
            }
        }
        .background(Color.AppBGColor.ignoresSafeArea())
    }
    
    var body: some View {
        NavigationLink(isActive: self.$isActive,destination: self.destinationView) {
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
        
    }
    
}


struct CustomNavLinkWithLabel<Label:View,Destination:View>: View {
    
    var label:Label? = nil
    var destination:Destination
    var mainHeaderView: ((CGSize) -> AnyView)?
    var rightSidebarView:(() -> AnyView)?
    
    init(@ViewBuilder label:() -> Label,@ViewBuilder destination: @escaping () -> Destination,mainHeaderView: ((CGSize) -> AnyView)? = nil,rightSidebarView:(() -> AnyView)? = nil){
        self.label = label()
        self.destination = destination()
        self.mainHeaderView = mainHeaderView
        self.rightSidebarView = rightSidebarView
    }


    @ViewBuilder func destinationView() -> some View{
        Group{
            if self.mainHeaderView != nil || self.rightSidebarView != nil {
                self.destination
                    .customNavBarContainerView(mainHeaderView: self.mainHeaderView, rightSidebarView: self.rightSidebarView)
            }else{
                self.destination
                    .navigationBarHidden(true)
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.AppBGColor.ignoresSafeArea())
    }
    
    var body: some View {
        NavigationLink(destination: self.destination) {
            self.label
        }
    }
}
