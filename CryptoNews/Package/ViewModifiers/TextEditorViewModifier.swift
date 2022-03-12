//
//  TextEditorViewModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

struct ColoredTextField:TextFieldStyle{
    var color:Color
    var fontSize:CGFloat = 25
    
    public init(color:Color,fontSize:CGFloat = 25){
        self.color = color
        self.fontSize = fontSize
    }
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(Font.system(size: self.fontSize, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
                .background(Color.clear)
                .clipContent(clipping: .clipped)
                .labelsHidden()
        }
}


public extension View{
    func coloredTextField(color:Color,size:CGFloat = 50,width:CGFloat = 100,rightViewTxt:String? = nil) -> some View{
        AnyView(self.textFieldStyle(ColoredTextField(color: color,fontSize: size))
                        .aspectRatio(contentMode:.fit)
                        .frame(width: width, alignment: .topLeading)
                        .truncationMode(.tail)
                        .keyboardType(.numberPad)
        )
    }
}
