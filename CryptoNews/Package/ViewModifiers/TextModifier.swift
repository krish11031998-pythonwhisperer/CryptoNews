//
//  TextModifiers.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/03/2022.
//

import SwiftUI

enum TextStyleModifier:String{
    case bullet = "circle"
}

struct TextModifiers: ViewModifier{
    var style:TextStyleModifier
    var foregroundColor:Color
    
    init(style:TextStyleModifier,foregroundColor:Color = .white){
        self.style = style
        self.foregroundColor = foregroundColor
    }
    
    @ViewBuilder var textStylizingView:some View{
        switch(self.style){
            case .bullet:
                Image(systemName: self.style.rawValue)
                    .resizable()
                    .frame(width: 7.5, height: 7.5, alignment: .center)
                    .foregroundColor(foregroundColor)
            default:
                Color.clear
                    .frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    func body(content: Content) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            self.textStylizingView
            content
        }
    }
}

extension View{
    func stylizeText(style:TextStyleModifier) -> some View{
        self.modifier(TextModifiers(style: .bullet))
    }
}
