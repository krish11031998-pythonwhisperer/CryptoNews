//
//  CustomTextViews.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public enum TextStyle:String{
    case heading = "Avenir"
    case normal = "Avenir Next"
    case monospaced = ""
}


public struct MainText: View {
    var content:String
    var fontSize:CGFloat
    var color:Color
    var font:Font
    var fontWeight:Font.Weight
    var style:TextStyle
    var addBG:Bool
    var padding:CGFloat
    
    public init(content:String,fontSize:CGFloat,color:Color = .white, fontWeight:Font.Weight = .thin,style:TextStyle = .normal,addBG:Bool = false,padding:CGFloat = 0){
        self.content = content.stripSpaces().removeEndLine()
        self.fontSize = fontSize
        self.color = color
        self.style = style
        self.font = .custom(self.style.rawValue, size: self.fontSize)
        self.fontWeight = fontWeight
        self.addBG = addBG
        self.padding = padding
    }
    
    struct CustomFontModifier:ViewModifier{
        var addBG:Bool
        var oppColor:Color
        var padding:CGFloat
        func body(content: Content) -> some View {
            
            content
                .padding(.all,self.padding)
                .background(self.addBG ? BlurView.thinDarkBlur.anyViewWrapper() : Color.clear.anyViewWrapper())
                .clipShape(RoundedRectangle(cornerRadius: addBG ? 20 : 0))
        }
        
    }
    
    var oppColor:Color{
        return self.color == .black ? .white : .black
    }
    
    var _font_:Font{
        return self.style != .monospaced ? .custom(self.style.rawValue, size: self.fontSize) : Font.system(size: self.fontSize, weight: .regular, design: .monospaced)
    }
    
    public var body: some View {
        Text(self.content)
            .font(_font_)
            .fontWeight(self.fontWeight)
            .foregroundColor(self.color)
            .modifier(CustomFontModifier(addBG: addBG, oppColor: oppColor,padding: self.padding))
    }
}

struct MainSubHeading:View{
    var heading:String
    var subHeading:String
    var headingSize:CGFloat
    var subHeadingSize:CGFloat
    var headingFont:TextStyle
    var headingWeight:Font.Weight
    var bodyWeight:Font.Weight
    var subHeadingFont:TextStyle
    var headColor:Color
    var spacing:CGFloat
    var subHeadColor:Color
    var alignment:Alignment
    var orientation:Axis
    var titleLine:Bool
    init(
        heading:String,
        subHeading:String,
        headingSize:CGFloat = 10,
        subHeadingSize:CGFloat = 13,
        headingFont:TextStyle = .heading,
        subHeadingFont:TextStyle = .normal,
        headColor:Color = .gray,
        subHeadColor:Color = .white,
        orientation:Axis = .vertical,
        headingWeight:Font.Weight = .semibold,
        bodyWeight:Font.Weight = .semibold,
        spacing:CGFloat = 5,
        titleLine:Bool = false,
        alignment:Alignment = .leading)
    {
        self.heading = heading
        self.subHeading = subHeading
        self.headingSize = headingSize
        self.subHeadingSize = subHeadingSize
        self.headingFont = headingFont
        self.subHeadingFont = subHeadingFont
        self.headingWeight = headingWeight
        self.bodyWeight = bodyWeight
        self.headColor = headColor
        self.subHeadColor = subHeadColor
        self.orientation = orientation
        self.alignment = alignment
        self.spacing = spacing
        self.titleLine = titleLine
    }
        
    @ViewBuilder var headingView:some View{
        if self.titleLine{
            VStack(alignment: .center, spacing: 2.5) {
                MainText(content: self.heading, fontSize: self.headingSize, color: headColor, fontWeight: self.headingWeight,style: headingFont)
                    .lineLimit(1)
                if self.titleLine{
                    Color.mainBGColor
                        .frame(height: 5, alignment: .center)
                        .clipContent(clipping: .roundClipping)
                }
            }.aspectRatio(contentMode: .fit)
        }else{
            MainText(content: self.heading, fontSize: self.headingSize, color: headColor, fontWeight: self.headingWeight,style: headingFont)
                .lineLimit(1)
        }
        
    }
    
    var body: some View{
        if self.orientation == .vertical{
            VStack(alignment: self.alignment.horizontal, spacing: spacing) {
                self.headingView
                MainText(content: self.subHeading, fontSize: self.subHeadingSize, color: subHeadColor, fontWeight: self.bodyWeight,style: subHeadingFont)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }else if self.orientation == .horizontal{
            HStack(alignment: self.alignment.vertical, spacing: spacing) {
                self.headingView
                MainText(content: self.subHeading, fontSize: self.subHeadingSize, color: subHeadColor, fontWeight: self.bodyWeight,style: subHeadingFont)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
     
}

