//
//  ContainerModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public enum Clipping:CGFloat{
    case roundClipping = 20
    case squareClipping = 10
    case roundCornerMedium = 15
    case circleClipping = 50
    case clipped = 0
}

public struct BorderCard:ViewModifier{
    var color:Color
    var clipping:Clipping
    
    public init(color:Color,clipping:Clipping = .roundClipping){
        self.color = color
        self.clipping = clipping
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: self.clipping.rawValue)
                    .stroke(self.color, lineWidth: 1)
            )
    }
    
}


public struct BasicCard:ViewModifier{
    var size:CGSize
    var background:AnyView
    
    public init(size:CGSize,background:AnyView = AnyView(BlurView.thinDarkBlur)){
        self.size = size
        self.background = background
    }
    
    @ViewBuilder func mainBody(_ content:Content) -> some View{
        if self.size != .zero{
            content
                .frame(width: self.size.width, height: self.size.height, alignment: .center)
        }else{
            content
        }
    }
    
    public func body(content: Content) -> some View {
        self.mainBody(content)
            .background(self.background)
            .clipContent(clipping: .roundClipping)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

public struct AsyncContainerModifier:ViewModifier{
    var g:GeometryProxy? = nil
    var axis:Axis = .vertical
    var size:CGSize = .zero
    @State var showView:Bool = false
    
    public init(g:GeometryProxy? = nil,axis:Axis = .vertical,size:CGSize = .zero){
        self.g = g
        self.axis = axis
        self.size = size
    }
    
    public init(g:GeometryProxy? = nil,size:CGSize = .zero){
        self.size = size
        self.g = g
    }

    
    func DispatchQueueAxis(_ g:GeometryProxy){
        
//        let minX = g.frame(in: .global).minX
//        let minY =
        let threshold = self.axis == .vertical ? totalHeight : totalWidth
        let checkvalue = self.axis == .vertical ?  g.frame(in: .global).minY :  g.frame(in: .global).minX
            
        setWithAnimation {
            if !self.showView && checkvalue < threshold{
                self.showView.toggle()
            }
        }
    }
    
    @ViewBuilder var progressView:some View{
        GeometryReader { g -> AnyView in
            self.DispatchQueueAxis(g)
            return ProgressView().frame(width: g.frame(in: .local).width, height: g.frame(in: .local).height, alignment: .center).anyViewWrapper()
        }.frame(width: totalWidth - 20, height: 25, alignment: .center)
    }
    
    public func body(content: Content) -> some View {
        if self.showView{
            content
        }else{
            self.progressView
        }
    }
    
}

public struct ContentClipping:ViewModifier{
    var clipping:Clipping
    
    public init(clipping:Clipping){
        self.clipping = clipping
    }

    public func body(content: Content) -> some View {
        if self.clipping == .circleClipping{
            content
                .contentShape(Circle())
                .clipShape(Circle())
        }else{
            content
                .contentShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
                .clipShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
        }
    }
}

public struct Blob:ViewModifier{
    var color:AnyView
    var clipping:Clipping
    var size:CGSize?
    
    public init(size:CGSize? = nil,color:AnyView,clipping:Clipping){
        self.color = color
        self.clipping = clipping
        self.size = size
    }
    
    @ViewBuilder func contentWithFrame(content:Content) -> some View{
        if let size = self.size{
            content
                .padding(10)
                .frame(width: size.width - 5, height: size.height - 5, alignment: .trailing)
        }else{
            content
                .padding(10)
        }
    }
    
    
    public func body(content: Content) -> some View {
        self.contentWithFrame(content: content)
            .background(color)
            .clipContent(clipping: self.clipping)
            .overlay(RoundedRectangle(cornerRadius: self.clipping.rawValue)
            .stroke(Color.mainBGColor, lineWidth: 2))
    }
}



public extension View{
    func basicCard(size:CGSize = .zero,background:AnyView = AnyView(BlurView.thinDarkBlur)) -> some View{
        self.modifier(BasicCard(size: size,background: background))
    }
    
    func borderCard(color:Color = .clear,clipping:Clipping = .roundClipping) -> some View{
        self.modifier(BorderCard(color: color, clipping: clipping))
    }
    
    func blobify(size:CGSize? = nil,color:AnyView = AnyView(Color.clear),clipping:Clipping = .squareClipping) -> some View{
        self.modifier(Blob(size:size,color: color,clipping: clipping))
    }
    
    func asyncContainer(g:GeometryProxy? = nil,axis:Axis = .vertical,size:CGSize = .zero) -> some View{
        self.modifier(AsyncContainerModifier(g: g, axis: axis, size: size))
    }
    
    func clipContent(clipping:Clipping = .clipped) -> some View{
        self.modifier(ContentClipping(clipping: clipping))
    }
}
