//
//  SwiftUIView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct BlurView:UIViewRepresentable{
    var style : UIBlurEffect.Style
    
    public init(style:UIBlurEffect.Style){
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: self.style))
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
    
    public static var thinDarkBlur:BlurView = .init(style: .systemUltraThinMaterialDark)
    public static var regularBlur:BlurView = .init(style: .regular)
    public static var thinLightBlur:BlurView = .init(style: .systemUltraThinMaterialLight)
}
