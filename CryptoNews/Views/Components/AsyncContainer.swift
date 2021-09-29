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
    var triggerAction:(() -> Void)
    init(size:CGSize,triggerAction:@escaping (() -> Void),@ViewBuilder view: () -> T){
        self.view = view()
        self.size = size
        self.triggerAction = triggerAction
    }
    
    var body: some View {
        GeometryReader { g -> AnyView in
            let maxY = g.frame(in: .global).maxY
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
//                if maxY <= totalHeight{
//                    self.triggerAction()
//                }
                if minY <= totalHeight{
                    self.triggerAction()
                }
                print("DEBUG : maxY = ",maxY)
            }
            
            return AnyView(self.view)
        }.frame(width: self.size.width, alignment: .center)
            .frame(maxHeight: .infinity)
    }
}

//struct AsyncContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncContainer()
//    }
//}
