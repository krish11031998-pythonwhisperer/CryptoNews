//
//  SystemButton.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 07/04/2021.
//

import SwiftUI

struct SystemButton: View {
    var buttonName:String?
    var buttonContent:String?
    var actionHandler: () -> Void
    var color:Color
    var haveBG:Bool
    var customIcon:String?
    var alignment:Axis.Set?
    var size:CGSize = .init(width: 10, height: 10)
    fileprivate var bgcolor:Color? = nil
    init(b_name:String? = nil,
         b_content:String? = nil,
         color:Color = .white,
         haveBG:Bool = true,
         size:CGSize? = nil,
         customIcon:String? = nil,
         bgcolor:Color? = nil,
         alignment:Axis.Set? = nil,
         action:@escaping () -> Void){
        self.buttonName = b_name
        self.buttonContent = b_content
        self.actionHandler = action
        self.color = color
        self.haveBG = haveBG
        self.bgcolor = bgcolor
        self.customIcon = customIcon
        self.alignment = alignment
        if let safeSize = size{
            self.size = safeSize
        }
    }
    
    var bgColor:Color{
        get{
            return self.bgcolor != nil ? self.bgcolor! : self.color == .white ? .black : .white
        }
    }
    
    @ViewBuilder var Img:some View {
        if let buttonName = self.buttonName{
            Image(systemName: buttonName)
                .resizable()
        }else if let customIcon = customIcon{
            Image(customIcon)
                .resizable()
        }
    }
    
    @ViewBuilder var ButtonImg:some View{
            if self.haveBG{
                self.Img
                    .systemButtonModifier(size: size, color: color, bg: {
                        AnyView(haveBG ? bgColor : Color.clear)
                    })
                
            }else{
                self.Img
                    .systemButtonModifier(size: size, color: color, bg: {
                        AnyView(Color.mainBGColor)
                    })
            }
    }
    
    @ViewBuilder var labelView:some View{

        if self.alignment == .vertical{
            VStack(alignment:.center,spacing:5){
                self.ButtonImg
                if let content = self.buttonContent{
                    MainText(content: content, fontSize: size.width,color: bgColor)
                }
                
            }
        }else if self.alignment == .horizontal{
            HStack(alignment:.center,spacing:5){
                self.ButtonImg
                if let content = self.buttonContent{
                    MainText(content: content, fontSize: size.width,color: bgColor)
                }
                
            }
        }else{
            self.ButtonImg
        }
    }
    
    var body: some View {
        self.labelView
            .buttonify(handler: self.actionHandler)
    }
}

//struct SystemButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SystemButton()
//    }
//}
