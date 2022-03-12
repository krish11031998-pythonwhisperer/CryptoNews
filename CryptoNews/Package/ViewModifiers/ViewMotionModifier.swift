//
//  ViewMotionModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 15/02/2022.
//

import SwiftUI

public enum ViewMotionModifierType{
    case zoomInOut
    case skewLeft
    case skewRight
    case skewTop
    case skewBottom
}

public struct ViewMotionModifier: ViewModifier{
    
    var axis:Axis
    var modifier_type:ViewMotionModifierType
    @State var localSize:CGSize = .zero
    
    public init(axis:Axis = .horizontal,modifier_type:ViewMotionModifierType = .zoomInOut){
        self.axis = axis
        self.modifier_type = modifier_type
    }
    
    func motionModifiedView(content:Content,g:GeometryProxy) -> some View{
        let scale = self.modifier_type == .zoomInOut ? self.computeZoomInOut(g: g) : 1
        let skew = self.modifier_type == .skewLeft || self.modifier_type == .skewRight || self.modifier_type == .skewTop || self.modifier_type == .skewBottom ? self.computeSkew(g: g) : (x:0,y:0,z:0)

        return content
            .scaleEffect(scale)
            .rotation3DEffect(.init(degrees: 15), axis: skew)
    }
    
    
    public func body(content: Content) -> some View {
        GeometryReader{g in
            self.motionModifiedView(content: content, g: g)
        }
    }
}

extension ViewMotionModifier{
    
    func computeZoomInOut(g:GeometryProxy) -> CGFloat{
        let midX = g.frame(in: .global).midX
        let diff = abs(midX - halfTotalWidth)/totalWidth
        let diff_percent = (diff > 0.25 ? 1 : diff/0.25)
        let scale = 1 - 0.075 * diff_percent
        return scale
    }
    
    func computeSkew(g:GeometryProxy) -> (x:CGFloat,y:CGFloat,z:CGFloat){
        let midX = g.frame(in: .global).midX
        let diff = (midX - halfTotalWidth)/totalWidth
        let diff_percent = diff > 0.25 ?  0.25 : (diff/0.25)
        let skew = 0 - diff_percent
        let x_skew = self.axis == .vertical ? CGFloat(self.x_skew_factor) * skew : 0
        let y_skew = self.axis == .horizontal ? CGFloat(self.y_skew_factor) * skew : 0
        return (x: x_skew, y: y_skew, z: 0)
    }
    
    var x_skew_factor:Int{
        var factor:Int = .zero
        switch(self.modifier_type){
            case .skewTop:
                factor = 1
                break
            case .skewBottom:
                factor = -1
                break
            default:
                factor = 0
        }
        return factor
    }
    
    var y_skew_factor:Int{
        var factor:Int = .zero
        switch(self.modifier_type){
            case .skewLeft:
                factor = 1
                break
            case .skewRight:
                factor = -1
                break
            default:
                factor = 0
        }
        return factor
    }
}

extension View{
    func motionModifiedView(axis:Axis,modifier:ViewMotionModifierType) -> some View{
        return self.modifier(ViewMotionModifier(axis: axis, modifier_type: modifier))
    }
}
