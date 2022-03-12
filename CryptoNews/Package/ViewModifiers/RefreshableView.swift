//
//  RefreshableView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct RefreshableView:ViewModifier{
    
    @Binding var refreshing:Bool
    @State var refresh_off:CGFloat = 0.0
    @State var pageRendered:Bool = false
    var hasToRender:Bool
    var width:CGFloat

    public init(refreshing:Binding<Bool> = .constant(false),width:CGFloat,hasToRender:Bool){
        self._refreshing = refreshing
        self.width = width
        self.hasToRender = hasToRender
    }
    
    func resetOff(){
        withAnimation(.easeInOut) {
            self.refresh_off = 0
        }
    }
    
    func refresh(minY:CGFloat){
        print("Refreshing.....")
        withAnimation(.easeInOut) {
            self.refreshing = true
            self.refresh_off = 100
            self.pageRendered = false
            print("DEBUG Refresh was toggled!")
        }
    }
    
    var refreshState:Bool{
        return !self.refreshing && self.refresh_off == 0 && self.pageRendered
    }
    
    var refreshableView:some View{
        GeometryReader{g -> AnyView in
            let minY = g.frame(in: .global).minY
            DispatchQueue.main.async {
                if self.hasToRender{
                    if !self.pageRendered && minY < 0{
                        self.pageRendered = true
                    }else if minY >= 100  && self.refreshState{
                        self.refresh(minY: minY)
                    }
                }
            }
            
           return AnyView(ZStack(alignment: .center) {
                if refreshing{
                    ProgressView()
                }else{
                    SystemButton(b_name: "arrow.down", b_content: "", color: .white, haveBG: false,bgcolor: .clear) {}
                }
           }.frame(width: width, alignment: .center)
            .onChange(of: self.refreshing) { newValue in
               if !newValue{
                   self.resetOff()
               }
           }
        )
                
            
        }
    }
    
    
    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            self.refreshableView.padding(.bottom,50)
            content
        }
        .frame(width: width, alignment: .top)
        .offset(y: -25 + self.refresh_off)
        .preference(key: RefreshPreference.self, value: self.refreshing)
    }
}


public extension View{
    func refreshableView(refreshing:Binding<Bool> = .constant(false),width:CGFloat,hasToRender:Bool) -> some View{
        self.modifier(RefreshableView(refreshing: refreshing,width: width,hasToRender: hasToRender))
    }
}
