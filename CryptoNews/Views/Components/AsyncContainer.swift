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
    
    @ViewBuilder var progressView: T{
        ProgressView() as! T
    }
    
    var body: some View {
//        VStack(alignment: .center, spacing: 0) {
        GeometryReader { g -> AnyView in
            let maxY = g.frame(in: .global).maxY
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if (minY <= totalHeight && !self.showView) || (minY >= totalHeight && self.showView){
                    self.showView.toggle()
                }
            }
            
            if self.showView{
                return AnyView(self.view)
            }else{
                return AnyView(ProgressView())
            }
        }
    }
}

//struct AsyncContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncContainer()
//    }
//}
