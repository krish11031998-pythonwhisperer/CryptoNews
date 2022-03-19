//
//  TransitionModifiers.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct SlideInOut:ViewModifier{
    var scale:CGFloat
    
    public init(scale:CGFloat){
        self.scale = scale
    }
    
    public func body(content: Content) -> some View {
        content
            .transition(.move(edge: .bottom))
    }
}

public struct SlidingZoomInOut:ViewModifier{
    var g:GeometryProxy? = nil
    var cardSize:CGSize
    var centralize:Bool
    @State var centralize_container:Bool = false
    
    public init(g:GeometryProxy? = nil,cardSize:CGSize,centralize:Bool){
        self.g = g
        self.cardSize = cardSize
        self.centralize = centralize
    }
    
    func scaleGen(g:GeometryProxy) -> CGFloat{
        let midX = g.frame(in: .global).midX
        let diff = abs(midX - (totalWidth * 0.5))/totalWidth
        let diff_percent = (diff > 0.25 ? 1 : diff/0.25)
        let scale = 1 - 0.075 * diff_percent
        if self.centralize{
            self.computeCenter(g: g)
        }
        return scale
    }
    
    func computeCenter(g:GeometryProxy){
        let midX = g.frame(in: .global).midX
        let diff = midX - totalWidth * 0.5
        if abs(diff) <= cardSize.width * 0.5{
            DispatchQueue.main.async {
                self.centralize_container = true
            }
        }
    }
    
    @ViewBuilder func mainBody(content: Content) -> some View{
        if let g = self.g{
            let scale = self.scaleGen(g: g)
            content.scaleEffect(scale)
        }else{
            GeometryReader{g -> AnyView in
                let scale = self.scaleGen(g: g)
                return AnyView(content.scaleEffect(scale))
            }.frame(width: self.cardSize.width, height: self.cardSize.height * 1.1, alignment: .center)
        }
    }
    
    public func body(content: Content) -> some View {
        if self.centralize{
            self.mainBody(content: content)
                .preference(key: CentralizePreference.self, value: self.centralize_container)
        }else{
            self.mainBody(content: content)
        }
        
    }
    
}

public struct ZoomInOut:ViewModifier{
    
    @State var scale:CGFloat
    @State var opacity:CGFloat
    
    public init(scale:CGFloat = 1.2,opacity:CGFloat = 0.8){
        self._scale = .init(initialValue: scale)
        self._opacity = .init(initialValue: opacity)
    }
    
    func onAppear(){
        withAnimation(.easeInOut) {
            self.scale = 1
            self.opacity = 1
        }
    }
    
    func onDisappear(){
        withAnimation(.easeInOut) {
            self.scale = 0.75
            self.opacity = 0.75
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.5))
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            
    }
}

public struct ImageTransition:ViewModifier{
    @State var load:Bool
    
    public init(){
        self._load = .init(initialValue: false)
    }
    
    func onAppear(){
        withAnimation(.easeInOut(duration: 0.5)) {
            self.load = true
        }
    }
    
    var scale:CGFloat{
        return self.load ? 1 : 1.075
    }
    
    public func body(content: Content) -> some View {
        return content
            .scaleEffect(self.scale)
            .onAppear(perform: self.onAppear)
    }
}


public extension AnyTransition{
    
    static var slideInOut:AnyTransition{
        return AnyTransition.asymmetric(insertion:.move(edge: .bottom), removal: .move(edge: .bottom))
    }
    
    static var zoomInOut:AnyTransition{
        return AnyTransition.asymmetric(insertion: .scale(scale: 1.5).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)).animation(.easeInOut)
    }

    static var slideRightLeft:AnyTransition{
        return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }
    
    static var slideLeftRight:AnyTransition{
        return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }
    
}

public extension View{
    
    func slideBottomRightToLeft() -> some View{
        self.transition(.move(edge: .bottom).combined(with: .move(edge: .trailing)))
    }

    func slideBottomLeftToRight() -> some View{
        self.transition(.move(edge: .bottom).combined(with: .move(edge: .leading)))
    }

    func imageSpring() -> some View{
        self.modifier(ImageTransition())
    }
    
    func zoomInOut() -> some View{
        self.modifier(ZoomInOut())
    }
    
    func slideZoomInOut(g:GeometryProxy? = nil,cardSize:CGSize,centralize:Bool = false) -> some View{
        self.modifier(SlidingZoomInOut(g: g,cardSize: cardSize,centralize:centralize))
    }
    
    func slideRightLeft() -> some View{
        self.transition(.slideRightLeft)
    }
    
    func slideLeftRight() -> some View{
        self.transition(.slideLeftRight)
    }
    
    func slideInOut() -> some View{
        self.transition(.slideInOut)
    }
}