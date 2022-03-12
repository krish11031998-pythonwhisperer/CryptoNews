//
//  ShadowModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct ShadowModifier:ViewModifier{
    public func body(content: Content) -> some View {
        content
            .shadow(color: .white.opacity(0.05), radius: 10, x: 0, y: 0)
    }
}

public extension View{
    func defaultShadow() -> some View{
        self.modifier(ShadowModifier())
    }
}
