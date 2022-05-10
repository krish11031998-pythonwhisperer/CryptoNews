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
        .background(Color.AppBGColor.ignoresSafeArea())
    }
}

struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationView {
            ZStack {
                Color.yellow.frame(width: totalWidth, alignment: .center).ignoresSafeArea()
                CustomNavLinkWithoutLabel(isActive:.constant(false)) {
                    Color.red.frame(width: totalWidth, alignment: .center)
                        .ignoresSafeArea()
                        .navigationBarHidden(true)
                        .customNavigationTitleAndSubTitle("Title")
                }
            }
        }
    }
}
