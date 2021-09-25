//
//  AsyncContainer.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/09/2021.
//

import SwiftUI

struct AsyncContainer: View {
    var view:AnyView
    var size:CGSize
    var triggerAction:() -> Void
    init(view:AnyView,size:CGSize,triggerAction:@escaping (() -> Void)){
        self.view = view
        self.size = size
        self.triggerAction = triggerAction
    }
    
    var body: some View {
        GeometryReader { g -> AnyView in
            let maxY = g.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                if maxY <= totalHeight{
                    self.triggerAction()
                }
            }
            
            return AnyView(self.view)
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
}

//struct AsyncContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncContainer()
//    }
//}
