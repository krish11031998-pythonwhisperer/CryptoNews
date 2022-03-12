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

struct CustomNavLink<Label:View,Destination:View>: View {
    
    var label:Label? = nil
    var destination:Destination
    var mainHeaderView: ((CGSize) -> AnyView)?
    var rightSidebarView:(() -> AnyView)?
    @Binding var active:Bool
    
    init(active:Binding<Bool>,@ViewBuilder label:() -> Label,@ViewBuilder destination: @escaping () -> Destination,mainHeaderView: ((CGSize) -> AnyView)? = nil,rightSidebarView:(() -> AnyView)? = nil){
        self._active = active
        self.label = label()
        self.destination = destination()
        self.mainHeaderView = mainHeaderView
        self.rightSidebarView = rightSidebarView
    }


    @ViewBuilder func destinationView() -> some View{
        if self.mainHeaderView != nil || self.rightSidebarView != nil {
            self.destination
                .customNavBarContainerView(mainHeaderView: self.mainHeaderView, rightSidebarView: self.rightSidebarView)
        }else{
            self.destination
                .navigationBarHidden(true)
        }
    }
    
    var body: some View {
        NavigationLink(isActive: $active,destination: self.destinationView) {
            self.label
        }
    }
}
