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
    var refreshToggle:Bool
    @State var refreshing:Bool = false
    init(heading:String,width:CGFloat = totalWidth,refresh:Bool = false,onClose:(() -> Void)? = nil,@ViewBuilder innerView: @escaping (CGFloat) -> T,leftView: (() -> T)? = nil){
        self.heading = heading
        self.innerView = innerView
        self.onClose = onClose
        self.width = width
        self.leftButton = leftView?() ?? nil
        self.refreshToggle = refresh
    }
    
    func refresh(){
        self.refreshing = true
        print("DEBUG Refresh was toggled!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.refreshing = false
            print("DEBUG Data refreshed!")
        }
    }
    
    
    var refreshView:some View{
        ZStack(alignment: .center) {
            if refreshing{
                ProgressView()
            }else{
                SystemButton(b_name: "arrow.down", b_content: "", color: .white, haveBG: false,bgcolor: .clear) {
                    print("Refereshing......")
                }
            }
        }
    }
    
    @ViewBuilder var mainBody:some View{
        let w = totalWidth - 30
        return VStack(alignment: .leading, spacing: 10) {
            if self.refreshToggle{
                self.refreshView.offset(y: -100)
            }
            HStack {
                if let onClose = self.onClose{
                    SystemButton(b_name: "xmark",action: onClose)
                }
                MainText(content: self.heading, fontSize: 30, color: .white, fontWeight: .semibold,style: .heading)
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
//        .padding(.vertical,10)
        .frame(width: self.width, alignment: .leading)
    }
    
    var body: some View {
        self.mainBody
    }
}
