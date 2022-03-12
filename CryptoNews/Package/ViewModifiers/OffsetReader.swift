//
//  OffsetReader.swif.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 07/03/2022.
//

import SwiftUI

public struct OffsetReader:ViewModifier{
    
    var coordinatedSpace:String?
    @Binding var offset:CGFloat
    
    
    init(coordinatedSpace:String? = nil,offset:Binding<CGFloat>){
        self.coordinatedSpace = coordinatedSpace
        self._offset = offset
    }
    
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy -> Color in
            
                    DispatchQueue.main.async {
                        if let coordinatedSpace = coordinatedSpace {
                            self.offset = proxy.frame(in: .named(coordinatedSpace)).minY
                        }else{
                            self.offset = proxy.frame(in: .global).maxY
                        }
                    }
                    
                    return Color.clear
                }
            
            )
    }
}

public extension View{
    func offsetReader(coordinatedSpace:String? = nil,offset:Binding<CGFloat>) -> some View{
        self.modifier(OffsetReader(coordinatedSpace: coordinatedSpace,offset: offset))
    }
}
