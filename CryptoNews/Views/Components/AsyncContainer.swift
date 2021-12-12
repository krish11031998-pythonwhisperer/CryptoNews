//
//  AsyncContainer.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/09/2021.
//

import SwiftUI

struct AsyncContainer<T:View>: View {
    var view:T
    var size:CGSize
    @State var showView:Bool = false
    init(size:CGSize = .init(width: totalWidth - 20, height: 25),@ViewBuilder view: () -> T){
        self.view = view()
        self.size = size
    }
    
    
    var progressView:some View{
        GeometryReader { g -> AnyView in
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if !self.showView && minY < totalHeight * 1.5{
                    withAnimation(.easeInOut) {
                        self.showView.toggle()
                    }
                }
            }
            
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 25, alignment: .center))
            
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
    
    var body: some View {
        if self.showView{
            self.view
        }else{
            self.progressView
        }
    }
}
