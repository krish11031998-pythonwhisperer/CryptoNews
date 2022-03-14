//
//  TabBarButtonView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct TabButton:View{
    var size:CGSize
    var title:String
    var color:Color
    var fontSize:CGFloat
    var action:() -> Void
    var flexible:Bool
    
    public init(width:CGFloat = totalWidth - 40, height:CGFloat = 50,title:String = "Button",fontSize:CGFloat = 15,textColor:Color = .white,flexible:Bool = false,action:@escaping () -> Void){
        self.size = .init(width: width, height: height)
        self.title = title
        self.color = textColor
        self.fontSize = fontSize
        self.flexible = flexible
        self.action = action
    }
    
    var flexibleView:some View{
        MainText(content: self.title, fontSize: self.fontSize, color: self.color, fontWeight: .semibold)
            .blobify(color: AnyView(BlurView.thinDarkBlur), clipping: .roundCornerMedium)
            .buttonify(handler: self.action)
    }
    
    var nonFlexibleView:some View{
        ZStack(alignment: .center) {
            Color.clear
            MainText(content: self.title, fontSize: 15, color: self.color, fontWeight: .semibold)
        }
        .blobify(size:self.size,color: BlurView.thinDarkBlur.anyViewWrapper(), clipping: .roundCornerMedium)
        .buttonify(handler: self.action)
    }
    
    public var body: some View{
        if self.flexible{
            self.flexibleView
        }else{
            self.nonFlexibleView
        }
    }
    
}
