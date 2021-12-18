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
    var axis:Axis
    @State var showView:Bool = false
    init(size:CGSize = .init(width: totalWidth - 20, height: 25),axis:Axis = .vertical,@ViewBuilder view: () -> T){
        self.view = view()
        self.size = size
        self.axis = axis
    }
    
    
    func DispatchQueueAxis(_ g:GeometryProxy){
        
        let minX = g.frame(in: .global).minX
        let minY = g.frame(in: .global).minY
        
        
        switch(self.axis){
            case .horizontal:
                DispatchQueue.main.async {
                    if !self.showView && minX < totalWidth * 1.2{
                        withAnimation(.easeInOut) {
                            self.showView.toggle()
                        }
                    }
                }
            case .vertical:
                DispatchQueue.main.async {
                    if !self.showView && minY < totalHeight * 1.5{
                        withAnimation(.easeInOut) {
                            self.showView.toggle()
                        }
                    }
                }
            default:
                break
        }
    }
    
    var progressView:some View{
        GeometryReader { g -> AnyView in
            
            self.DispatchQueueAxis(g)
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
