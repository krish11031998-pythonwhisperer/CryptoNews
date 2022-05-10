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
//        .frame(width: totalWidth, height: totalHeight, alignment: .center)
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
