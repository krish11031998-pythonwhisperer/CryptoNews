//
//  PositionalModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/03/2022.
//

import SwiftUI

enum PositionalViewPosition{
    case top
    case bottom
    case left
    case right
}


struct PositionalViewModifier<T:View>: ViewModifier{
    var orientation:Axis
    var alignment:Alignment
    var otherView:T
    var position:PositionalViewPosition
    
    init(orientation:Axis,alignment:Alignment,position:PositionalViewPosition,@ViewBuilder otherView:@escaping () -> T){
        self.orientation = orientation
        self.alignment = alignment
        self.position = position
        self.otherView = otherView()
    }
    
    
    @ViewBuilder func innerBody(content:Content) -> some View{
        if self.position == .top || self.position == .left{
            self.otherView
        }
        content
        if self.position == .bottom || self.position == .right{
            self.otherView
        }
    }
    
    @ViewBuilder func body(content: Content) -> some View {
        if self.orientation == .vertical{
            VStack(alignment: self.alignment.horizontal, spacing: 10) {
                self.innerBody(content: content)
            }
        }else{
            HStack(alignment: self.alignment.vertical, spacing: 10) {
                self.innerBody(content: content)
            }
        }
    }
}


extension View{
    func makeAdjacentView<T:View>(orientation:Axis = .vertical,alignment:Alignment = .leading,position:PositionalViewPosition,@ViewBuilder otherView: @escaping () -> T) -> some View{
        self.modifier(PositionalViewModifier(orientation: orientation,alignment: alignment, position: position, otherView: otherView))
    }
}
