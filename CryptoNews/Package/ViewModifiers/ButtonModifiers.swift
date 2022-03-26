//
//  ButtonModifiers.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 06/01/2022.
//

import SwiftUI

public enum ButtonType{
    case spring
    case shadow
}

public struct SpringButton:ViewModifier{
    var withBG:Bool
    var clipping:Clipping
    var handleTap:(() -> Void)
    
    public init(withBG:Bool = false,clipping:Clipping = .clipped,handleTap: @escaping () -> Void){
        self.withBG = withBG
        self.clipping = clipping
        self.handleTap = handleTap
    }
    
    public func body(content: Content) -> some View {
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

public struct ShadowSpringButton:ViewModifier{
    var withShadow:Bool
    var bg:AnyView? = nil
    var handleTap:(() -> Void)
    
    public init(withShadow:Bool = true,bg:AnyView? = nil,handler:@escaping () -> Void){
        self.withShadow = withShadow
        self.handleTap = handler
        self.bg = bg
    }
    
    public func body(content: Content) -> some View {
        Button {
            setWithAnimation {
                self.handleTap()
            }
        } label: {
            content
                .contentShape(Rectangle())
        }
        .shadowButton(withShadow: self.withShadow,bg: self.bg)

    }
}

public struct SpringButtonModifier:ButtonStyle{
    
    var withBG:Bool = false
    var clipping:Clipping
    
    public init(withBG:Bool = false,clipping:Clipping = .clipped){
        self.withBG = withBG
        self.clipping = clipping
    }
    
    
    public func makeBody(configuration: Configuration) -> some View {
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


public struct ShadowButtonModifier:ButtonStyle{
    var withShadow:Bool
    var bg:AnyView? = nil
    
    public init(withShadow:Bool = true,bg:AnyView? = nil){
        self.withShadow = withShadow
        self.bg = bg
    }
    
    var color:Color{
        return self.withShadow ? .black.opacity(0.5) : .clear
    }
    
    @ViewBuilder func background(isPressed:Bool) -> some View{
        if isPressed{
            BlurView.thinLightBlur
                .scaleEffect(isPressed ? 1.05 : 1)
//            Color.white
        }else{
            if let bg = self.bg{
                bg.scaleEffect(isPressed ? 1.05 : 1)
            }else{
                Color.clear.scaleEffect(isPressed ? 1.05 : 1)
            }
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .scaleEffect(isPressed ? 0.95 : 1)
            .opacity(isPressed ? 0.95 : 1)
            .background(self.background(isPressed: isPressed))
            .clipContent(clipping: .roundClipping)
            .shadow(color: self.color, radius: isPressed ? 1.5 : 0, x: 0, y: 0)
            
    }
}

public struct ButtonClickedHighlightView:ViewModifier{
    var selected:Bool
    var clipping:Clipping
    var color:Color?
    
    public init(selected:Bool = false,clipping:Clipping = .roundClipping,color:Color? = nil){
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
    
    public func body(content: Content) -> some View {
        content
            .overlay(selectiveBorder)
    }
}

public struct SystemButtonModifier:ViewModifier{
    var bg:AnyView
    var size:CGSize
    var color:Color
    
    public init(size:CGSize,color:Color,@ViewBuilder bg:() -> AnyView){
        self.size = size
        self.color = color
        self.bg = bg()
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(width: self.size.width, height: self.size.height, alignment: .center)
            .foregroundColor(color)
            .padding(10)
            .background(bg)
            .clipShape(Circle())
            .contentShape(Rectangle())
    }
}


public extension View{
    func springButton(withBG:Bool = false,clipping:Clipping = .clipped) -> some View{
        self.buttonStyle(SpringButtonModifier(withBG: withBG,clipping: clipping))
    }
    
    func shadowButton(withShadow:Bool,bg:AnyView? = nil) -> some View{
        self.buttonStyle(ShadowButtonModifier(withShadow: withShadow,bg: bg))
    }
    
    @ViewBuilder func buttonify(type:ButtonType = .spring,bg:AnyView? = nil,withBG:Bool = false,clipping:Clipping = .clipped,handler:@escaping () -> Void) -> some View{
        if type == .spring{
            self.modifier(SpringButton(withBG: withBG,clipping: clipping,handleTap: handler))
        }else if type == .shadow{
            self.modifier(ShadowSpringButton(withShadow: withBG,bg: bg, handler: handler))
        }
        
    }
    
    func buttonclickedhighlight(selected:Bool = false,clipping:Clipping = .roundClipping,color:Color? = nil) -> some View{
        self.modifier(ButtonClickedHighlightView(selected: selected, clipping: clipping, color: color))
    }
    
    func systemButtonModifier(size:CGSize,color:Color,@ViewBuilder bg: () -> AnyView) -> some View{
        self.modifier(SystemButtonModifier(size: size, color: color, bg: bg))
    }
}
