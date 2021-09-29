//
//  Container.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 12/08/2021.
//

import SwiftUI

struct Container<T:View>: View {
     var innerView:(CGFloat) -> T
    var leftButton:T? = nil
    var heading:String
    var onClose:(() -> Void)? = nil
    var width:CGFloat
    init(heading:String,width:CGFloat = totalWidth,onClose:(() -> Void)? = nil,@ViewBuilder innerView: @escaping (CGFloat) -> T,leftView: (() -> T)? = nil){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.leftButton = leftView?() ?? nil
    }
    
    @ViewBuilder var body: some View {
        let w = totalWidth - 30
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let onClose = self.onClose{
                    SystemButton(b_name: "xmark",action: onClose)
                }
                MainText(content: self.heading, fontSize: 30, color: .white, fontWeight: .semibold).padding(.horizontal)
                Spacer()
                if leftButton != nil{
                    self.leftButton
                }
            }
            Divider().frame(width:w * 0.5,alignment: .leading)
                .padding(.bottom,10)
            self.innerView(w)
        }
        .padding(.horizontal,15)
        .padding(.vertical,10)
        .frame(width: self.width, alignment: .leading)
    }
}
