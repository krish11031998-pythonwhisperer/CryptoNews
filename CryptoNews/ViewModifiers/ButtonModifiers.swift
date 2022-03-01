//
//  ButtonModifiers.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

enum ButtonType{
    case spring
    case shadow
}

struct SpringButton:ViewModifier{
    var withBG:Bool
    var clipping:Clipping
    var handleTap:(() -> Void)
    
    init(withBG:Bool = false,clipping:Clipping = .clipped,handleTap: @escaping () -> Void){
        self.withBG = withBG
        self.clipping = clipping
        self.handleTap = handleTap
    }
    
    func body(content: Content) -> some View {
        Button {
            setWithAnimation {
                self.handleTap()
            }
        } label: {
            content
                .contentShape(Rectangle())
        }.springButton(withBG: withBG,clipping: clipping)
    }
}

struct ShadowSpringButton:ViewModifier{
    var withShadow:Bool
    var handleTap:(() -> Void)
    init(withShadow:Bool = true,handler:@escaping () -> Void){
        self.withShadow = withShadow
        self.handleTap = handler
    }
    
    func body(content: Content) -> some View {
        Button {
            setWithAnimation {
                self.handleTap()
            }
        } label: {
            content
        }.clipContent(clipping: .roundClipping)
            .shadowButton(withShadow: self.withShadow)

    }
}
struct SpringButtonModifier:ButtonStyle{
    
    var withBG:Bool = false
    var clipping:Clipping
    init(withBG:Bool = false,clipping:Clipping = .clipped){
        self.withBG = withBG
        self.clipping = clipping
    }
    
    
    func makeBody(configuration: Configuration) -> some View {
        if self.withBG{
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
                .opacity(configuration.isPressed ? 0.9 : 1)
                .background((self.withBG ? AnyView(BlurView.thinDarkBlur) : AnyView(Color.clear)).opacity(configuration.isPressed ? 1 : 0).clipContent(clipping: self.clipping))
                
        }else{
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
                .opacity(configuration.isPressed ? 0.9 : 1)
        }
    }
}


struct ShadowButtonModifier:ButtonStyle{
    var withShadow:Bool
    init(withShadow:Bool = true){
        self.withShadow = withShadow
    }
    
    var color:Color{
        return self.withShadow ? .black.opacity(0.5) : .clear
    }
    
    @ViewBuilder func background(isPressed:Bool) -> some View{
        if isPressed{
            BlurView.thinLightBlur
//            Color.white
        }else{
            Color.clear
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(self.background(isPressed: configuration.isPressed))
            .clipContent(clipping: .roundClipping)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .shadow(color: self.color, radius: configuration.isPressed ? 1.5 : 0, x: 0, y: 0)
            
    }
}

struct ButtonClickedHighlightView:ViewModifier{
    var selected:Bool
    var clipping:Clipping
    var color:Color?
    
    init(selected:Bool = false,clipping:Clipping = .roundClipping,color:Color? = nil){
        self.selected = selected
        self.clipping = clipping
        self.color = color
    }
    
    
    @ViewBuilder var selectiveBorder:some View{
        if self.selected{
            if let color = self.color{
                RoundedRectangle(cornerRadius: self.clipping.rawValue)
                    .stroke(color,lineWidth: 1.25)
            }else{
                RoundedRectangle(cornerRadius: self.clipping.rawValue)
                    .stroke(Color.mainBGColor,lineWidth: 1.25)
            }
        }else{
            RoundedRectangle(cornerRadius: self.clipping.rawValue)
                .stroke(Color.gray,lineWidth: 1.25)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(selectiveBorder)
    }
    
}

extension View{
    func springButton(withBG:Bool = false,clipping:Clipping = .clipped) -> some View{
        self.buttonStyle(SpringButtonModifier(withBG: withBG,clipping: clipping))
    }
    
    func shadowButton(withShadow:Bool) -> some View{
        self.buttonStyle(ShadowButtonModifier(withShadow: withShadow))
    }
    
    @ViewBuilder func buttonify(type:ButtonType = .spring,withBG:Bool = false,clipping:Clipping = .clipped,handler:@escaping () -> Void) -> some View{
        if type == .spring{
            self.modifier(SpringButton(withBG: withBG,clipping: clipping,handleTap: handler))
        }else if type == .shadow{
            self.modifier(ShadowSpringButton(withShadow: withBG, handler: handler))
        }
        
    }
    
    func buttonclickedhighlight(selected:Bool = false,clipping:Clipping = .roundClipping,color:Color? = nil) -> some View{
        self.modifier(ButtonClickedHighlightView(selected: selected, clipping: clipping, color: color))
    }
    
}
