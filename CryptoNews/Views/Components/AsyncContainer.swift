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
    init(size:CGSize,@ViewBuilder view: () -> T){
        self.view = view()
        self.size = size
    }
    
    
    var progressView:some View{
        GeometryReader { g -> AnyView in
            let maxY = g.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                if !self.showView && maxY < totalHeight{
                    withAnimation(.easeInOut) {
                        self.showView.toggle()
                    }
                }
            }
            
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 25, alignment: .center))
            
        }
    }
    
    
    var body: some View {
        if self.showView{
            self.view
        }else{
            self.progressView
        }
    }
}
