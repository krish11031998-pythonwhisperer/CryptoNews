//
//  RotationModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/01/2022.
//

import SwiftUI

public struct FlipRotation:ViewModifier{
    @Binding var rotate:Bool
    
    
    public init(rotate:Binding<Bool>){
        self._rotate = rotate
    }
    
    var rotationAngle:Double{
        self.rotate ? 180 : 0
    }
    
    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0.5,y:0.0,z:0.0))
            .animation(.spring(response: 0.75, dampingFraction: 0.75, blendDuration: 0.125))
    }
}

public extension View{
    func flipRotation(rotate:Binding<Bool>) -> some View{
        self.modifier(FlipRotation(rotate: rotate))
    }
}
