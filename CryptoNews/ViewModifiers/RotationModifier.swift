//
//  RotationModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/01/2022.
//

import SwiftUI

struct FlipRotation:ViewModifier{
    @Binding var rotate:Bool
    
    var rotationAngle:Double{
        self.rotate ? 180 : 0
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0.5,y:0.0,z:0.0))
            .animation(.spring(response: 1, dampingFraction: 0.75, blendDuration: 0.125))
    }
}

extension View{
    func flipRotation(rotate:Binding<Bool>) -> some View{
        self.modifier(FlipRotation(rotate: rotate))
    }
}
