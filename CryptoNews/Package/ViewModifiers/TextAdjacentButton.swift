//
//  TextAdjacentButto.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/03/2022.
//

import SwiftUI

enum ViewAdjacentButtonSide{
    case left
    case right
    case top
    case bottom
}

struct ViewAdjacentButtonViewModifier:ViewModifier{
    var buttonName:String
    var onTapHandler:() -> Void
    var orientation:ViewAdjacentButtonSide
    var color:Color
    var bgColor:Color
    var hasBG:Bool
    var size:CGSize
    var customIcon:String?
    var borderedBG:Bool
    
    init(
        buttonName:String,
        orientation:ViewAdjacentButtonSide,
        color:Color = .white,
        bgColor:Color = .black,
        hasBG:Bool = false,
        size:CGSize = .init(width: 15, height: 15),
        customIcon:String? = nil,
        borderedBG:Bool = false,
        onTapHandler:@escaping () -> Void
    )
    {
        self.buttonName = buttonName
        self.color = color
        self.bgColor = bgColor
        self.hasBG = hasBG
        self.size = size
        self.customIcon = customIcon
        self.borderedBG = borderedBG
        self.onTapHandler = onTapHandler
        self.orientation = orientation
    }
    
    
    var buttonView:some View{
        SystemButton(b_name: self.buttonName, color: self.color, haveBG: self.hasBG, size: self.size, customIcon: self.customIcon, bgcolor: self.bgColor, borderedBG: self.borderedBG, clipping: .roundClipping, action: self.onTapHandler)
    }
    
    @ViewBuilder func body(content: Content) -> some View {
        if self.orientation == .left || self.orientation == .right{
            HStack(alignment: .center, spacing: 10) {
                if self.orientation == .left{
                    self.buttonView
                }
                content
                if self.orientation == .right{
                    self.buttonView
                }
            }
        }else if self.orientation == .top || self.orientation == .left{
            VStack(alignment: .center, spacing: 10) {
                if self.orientation == .top{
                    self.buttonView
                }
                content
                if self.orientation == .bottom{
                    self.buttonView
                }
            }
        }
    }
}

extension View{
    func viewAdjacentButton(buttonName:String,
                            orientation:ViewAdjacentButtonSide,
                            color:Color = .white,
                            bgColor:Color = .black,
                            hasBG:Bool = false,
                            size:CGSize = .init(width: 15, height: 15),
                            customIcon:String? = nil,
                            borderedBG:Bool = false,
                            onTapHandler:@escaping () -> Void) -> some View
    {
        self.modifier(ViewAdjacentButtonViewModifier(buttonName: buttonName, orientation: orientation, color: color, bgColor: bgColor, hasBG: hasBG, size: size, customIcon: customIcon, borderedBG: borderedBG, onTapHandler: onTapHandler))
    }
}
