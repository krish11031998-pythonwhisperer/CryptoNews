//
//  SlideUpAnimation.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/03/2022.
//

import SwiftUI
struct SlideUpAnimation: ViewModifier{
    
    @State var showContainer:Bool = false
    var idx:Int
    
    init(idx:Int = 0){
        self.idx = idx
    }
    
    func onAppearAnimation(){
        if !self.showContainer{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100 + idx * 50)) {
                self.showContainer.toggle()
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(self.showContainer ? 1 : 0)
            .offset(y: self.showContainer ? 0 : 200)
            .onAppear(perform: self.onAppearAnimation)
            .animation(.easeInOut)
    }
}

extension View{
    func animatedAppearance(idx:Int = 0) -> some View{
        self.modifier(SlideUpAnimation(idx: idx))
    }
}
