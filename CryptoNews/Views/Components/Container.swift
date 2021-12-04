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
    var orientation:Axis
    var paddingSize:CGSize = .zero
    init(
        heading:String? = nil,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        horizontalPadding:CGFloat = 15,
        verticalPadding:CGFloat = 10,
        orientation:Axis = .vertical,
        onClose:(() -> Void)? = nil,
        @ViewBuilder innerView: @escaping (CGFloat) -> T
    ){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.orientation = orientation
        self.ignoreSides = ignoreSides
        self.rightButton = nil
        self.paddingSize = .init(width: horizontalPadding, height: verticalPadding)
    }
    
    
    init(
        heading:String? = nil,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        horizontalPadding:CGFloat = 15,
        verticalPadding:CGFloat = 10,
        orientation:Axis = .vertical,
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
        self.orientation = orientation
        self.paddingSize = .init(width: horizontalPadding, height: verticalPadding)
    }
    
    var innerWidth:CGFloat{
        return width - (self.paddingSize.width * 2)
    }
    
    
    @ViewBuilder var onCloseView:some View{
        if let close = self.onClose{
            SystemButton(b_name: "xmark",action: close)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    var headingView: some View{
        let heading = self.heading!
        return Group{
            HStack {
                self.onCloseView
                MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold,style: .heading)
                Spacer()
                if rightButton != nil{
                    self.rightButton?()
                }
            }.padding(.horizontal,self.ignoreSides ? self.paddingSize.width : 0)
            Divider().frame(width:self.innerWidth * 0.5,alignment: .leading)
                .padding(.bottom,10)
                .padding(.horizontal,self.ignoreSides ? self.paddingSize.width : 0)
        }
        
    }
    
    var mainInnerView:some View{
        Group{
            if self.heading != nil{
                self.headingView
            }else if self.onClose != nil{
                self.onCloseView
            }
            self.innerView(self.innerWidth)
        }
    }
    
    
    @ViewBuilder var mainBody:some View{
    
        if self.orientation == .vertical{
            VStack(alignment: .leading, spacing: 20) {
                self.mainInnerView
            }
        }else if self.orientation == .horizontal{
            HStack(alignment: .center, spacing: 20) {
                self.mainInnerView
            }
        }
        
        
       
        
    }
    
    var body: some View {
        self.mainBody
            .padding(.horizontal, self.ignoreSides ? 0 : self.paddingSize.width)
            .padding(.vertical,self.paddingSize.height)
            .frame(width: self.width, alignment: .leading)
    }
}
