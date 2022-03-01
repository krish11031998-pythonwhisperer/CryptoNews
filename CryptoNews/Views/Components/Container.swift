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
    var alignment:Alignment
    var spacing:CGFloat
    var lazyLoad:Bool
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
        aligment:Alignment = .leading,
        spacing:CGFloat = 15,
        lazyLoad:Bool = false,
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
        self.spacing = spacing
        self.alignment = aligment
        self.lazyLoad = lazyLoad
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
        alignment:Alignment = .center,
        onClose:(() -> Void)? = nil,
        rightView: (() -> AnyView)? = nil,
        spacing:CGFloat = 15,
        lazyLoad:Bool = false,
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
        self.alignment = alignment
        self.spacing = spacing
        self.lazyLoad = lazyLoad
        self.paddingSize = .init(width: horizontalPadding, height: verticalPadding)
    }
    
    var innerWidth:CGFloat{
        return width - (self.ignoreSides ? 0 : self.paddingSize.width * 2)
    }
    
    
    @ViewBuilder var onCloseView:some View{
        if let close = self.onClose{
            SystemButton(b_name: "xmark",action: close)
        }else{
            Color.clear.frame(width: .zero, height: .zero, alignment: .center)
        }
    }
    
    @ViewBuilder func headingTitle(heading:String) -> some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: heading, fontSize: self.headingSize, color: self.headingColor, fontWeight: .semibold,style: .heading)
            if self.headingDivider{
                RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                    .fill(Color.mainBGColor)
                    .frame(height:2)
            }
        }.aspectRatio(contentMode: .fit)
    }
    
    
    @ViewBuilder var headerView:some View{
        HStack {
            if let close = self.onClose{
                SystemButton(b_name: "xmark",action: close)
            }
            if let heading = self.heading{
                self.headingTitle(heading: heading)
            }
            Spacer()
            if rightButton != nil{
                self.rightButton?()
            }
        }.padding(.horizontal,self.ignoreSides ? self.paddingSize.width : .zero)
    }
    
    @ViewBuilder var mainBodyWElements:some View{
        if self.lazyLoad{
            if self.orientation == .vertical{
                LazyVStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                    self.headerView.frame(width:self.innerWidth,alignment: .leading)
                        .padding(.bottom,10)
                    self.innerView(self.innerWidth)
                }
            }else if self.orientation == .horizontal{
                LazyVStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                    self.headerView.frame(width:self.innerWidth,alignment: .leading)
                        .padding(.bottom,10)
                    HStack(alignment: .center, spacing: self.spacing) {
                        self.innerView(self.innerWidth)
                    }
                }
            }
        }else{
            if self.orientation == .vertical{
                VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                    self.headerView.frame(width:self.innerWidth,alignment: .leading)
                        .padding(.bottom,10)
                    self.innerView(self.innerWidth)
                }
            }else if self.orientation == .horizontal{
                VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                    self.headerView.frame(width:self.innerWidth,alignment: .leading)
                        .padding(.bottom,10)
                    HStack(alignment: .center, spacing: self.spacing) {
                        self.innerView(self.innerWidth)
                    }
                }
            }
        }
        
    }
    
    @ViewBuilder var mainBody:some View{
        if self.lazyLoad{
            LazyVStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                if self.orientation == .vertical{
                    self.innerView(self.innerWidth)
                }else if self.orientation == .horizontal{
                    HStack(alignment: .center, spacing: self.spacing) {
                        self.innerView(self.innerWidth)
                    }
                }
            }
        }else{
            VStack(alignment: self.alignment.horizontal, spacing: self.spacing) {
                if self.orientation == .vertical{
                    self.innerView(self.innerWidth)
                }else if self.orientation == .horizontal{
                    HStack(alignment: .center, spacing: self.spacing) {
                        self.innerView(self.innerWidth)
                    }
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
