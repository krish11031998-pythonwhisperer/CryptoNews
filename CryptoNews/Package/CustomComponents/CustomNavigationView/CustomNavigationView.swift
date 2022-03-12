//
//  CustomNavigationView.swift
//  ClassicCars
//
//  Created by Krishna Venkatramani on 07/03/2022.
//

import SwiftUI

struct CustomNavigationView<Content:View>: View {
    
    var content:Content
    
    init(@ViewBuilder content: @escaping () -> Content){
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            self.content
                .navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationView {
            ZStack {
                Color.yellow.frame(width: totalWidth, alignment: .center).ignoresSafeArea()
                CustomNavLink (active:.constant(false)){
                    MainText(content: "Click Me", fontSize: 20, color: .black, fontWeight: .medium)
                        .padding(5)
                        .blobify(clipping:.roundClipping)
                } destination: {
                    Color.red.frame(width: totalWidth, alignment: .center)
                        .ignoresSafeArea()
                        .navigationBarHidden(true)
                        .customNavigationTitleAndSubTitle("Title")
                }
            }
        }
    }
}
