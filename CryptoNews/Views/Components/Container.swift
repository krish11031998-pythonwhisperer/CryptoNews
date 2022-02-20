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
    var headingDivider:Bool
    var headingColor:Color
    var headingSize:CGFloat
    var onClose:(() -> Void)? = nil
    var width:CGFloat
    var ignoreSides:Bool
    var refreshFn:(() -> Void)? = nil
    var orientation:Axis
    var paddingSize:CGSize = .zero
    init(
        heading:String? = nil,
        headingColor:Color = .white,
        headingDivider:Bool = true,
        headingSize:CGFloat = 30,
        width:CGFloat = totalWidth,
        ignoreSides:Bool = false,
        horizontalPadding:CGFloat = 15,
        verticalPadding:CGFloat = 10,
        orientation:Axis = .vertical,
        onClose:(() -> Void)? = nil,
        @ViewBuilder innerView: @escaping (CGFloat) -> T
    ){
        self.heading = heading
        self.headingColor = headingColor
        self.headingDivider = headingDivider
        self.headingSize = headingSize
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
        headingColor:Color = .white,
        headingDivider:Bool = true,
        headingSize:CGFloat = 30,
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
        self.headingColor = headingColor
        self.headingDivider = headingDivider
        self.headingSize = headingSize
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
    
    @ViewBuilder var headingTitle:some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: self.heading!, fontSize: self.headingSize, color: self.headingColor, fontWeight: .semibold,style: .heading)
            if self.headingDivider{
                RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                    .fill(Color.mainBGColor)
                    .frame(height:2)
            }
        }.aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder var headingView: some View{
        let heading = self.heading!
        HStack {
            if let close = self.onClose{
                SystemButton(b_name: "xmark",action: close)
            }
            self.headingTitle
            Spacer()
            if rightButton != nil{
                self.rightButton?()
            }
        }
    }
    
    @ViewBuilder var headerView:some View{
        if self.heading != nil{
            self.headingView
        }
//        else if self.onClose != nil{
//            self.onCloseView
//        }
        else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder var mainBodyWElements:some View{
        if self.orientation == .vertical{
            VStack(alignment: .center, spacing: 10) {
                self.headerView.frame(width:self.innerWidth,alignment: .leading)
                self.innerView(self.innerWidth).padding(.top,10)
            }
        }else if self.orientation == .horizontal{
            VStack(alignment: .center, spacing: 10) {
                self.headerView.frame(width:self.innerWidth,alignment: .leading)
                HStack(alignment: .center, spacing: 10) {
                    self.innerView(self.innerWidth).padding(.top,10)
                }
            }
        }
    }
    
    @ViewBuilder var mainBody:some View{
        VStack(alignment: .center, spacing: 10) {
            if self.orientation == .vertical{
                self.innerView(self.innerWidth)
            }else if self.orientation == .horizontal{
                HStack(alignment: .center, spacing: 10) {
                    self.innerView(self.innerWidth)
                }
            }
        }
        
    }

    
    var body: some View {
        if self.heading != nil || self.onClose != nil{
            self.mainBodyWElements
                .padding(.horizontal, self.ignoreSides ? 0 : self.paddingSize.width)
                    .padding(.vertical,self.paddingSize.height)
                    .frame(width: self.width, alignment: .leading)
        }else{
            self.mainBody
                .padding(.horizontal, self.ignoreSides ? 0 : self.paddingSize.width)
                    .padding(.vertical,self.paddingSize.height)
                    .frame(width: self.width, alignment: .leading)
        }
    }
}
