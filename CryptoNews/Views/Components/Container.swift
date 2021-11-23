//
//  Container.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/08/2021.
//

import SwiftUI

struct Container<T:View>: View {
    var innerView:(CGFloat) -> T
    var rightButton:(() -> AnyView)? = nil
    var heading:String?
    var onClose:(() -> Void)? = nil
    var width:CGFloat
    var ignoreSides:Bool
    var refreshFn:(() -> Void)? = nil
    init(
        heading:String? = nil,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        onClose:(() -> Void)? = nil,
        @ViewBuilder innerView: @escaping (CGFloat) -> T
    ){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.ignoreSides = ignoreSides
        self.rightButton = nil
    }
    
    
    init(
        heading:String? = nil,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        onClose:(() -> Void)? = nil,
        rightView: (() -> AnyView)? = nil,
        @ViewBuilder innerView: @escaping (CGFloat) -> T
    ){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.rightButton = rightView
        self.ignoreSides = ignoreSides
    }
    
    func headingView(heading:String,w:CGFloat) -> some View{
        return Group{
            HStack {
                if let onClose = self.onClose{
                    SystemButton(b_name: "xmark",action: onClose)
                }
                MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold,style: .heading)
                Spacer()
                if rightButton != nil{
                    self.rightButton?()
                }
            }.padding(.horizontal,self.ignoreSides ? 15 : 0)
            Divider().frame(width:w * 0.5,alignment: .leading)
                .padding(.bottom,10)
                .padding(.horizontal,self.ignoreSides ? 15 : 0)
        }
        
    }
    
    @ViewBuilder var mainBody:some View{
        let w = width - 30
        VStack(alignment: .leading, spacing: 10) {
            if let heading = self.heading{
                self.headingView(heading:heading,w: w)
            }
            self.innerView(w).padding(.top,10)
        }.padding(.horizontal, self.ignoreSides ? 0 : 15)
        .frame(width: self.width, alignment: .leading)
       
        
    }
    
    var body: some View {
        self.mainBody
    }
}
