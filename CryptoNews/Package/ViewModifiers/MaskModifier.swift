//
//  MaskModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/03/2022.
//

import SwiftUI

struct MaskModifier<T:View>:ViewModifier{
    var bgView:T
    
    init(@ViewBuilder bgView: @escaping () -> T){
        self.bgView = bgView()
    }
    
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 15.0, *){
            content
                .overlay(bgView.mask(content))
        }else{
            content
        }
    }
}


extension View{
    func maskView<T:View>(@ViewBuilder bgView: @escaping () -> T) -> some View{
        self.modifier(MaskModifier(bgView: bgView))
    }
}
