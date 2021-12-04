//
//  TestFile.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 19/11/2021.
//

import SwiftUI

struct TestView: View {
    
    
    
    var body: some View {
        GeometryReader{g in
            let size = g.frame(in: .local)
            
            VStack(alignment: .center, spacing: 10) {
                ForEach(Array(0...5),id:\.self){ _ in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(0.5))
                        .frame(width: size.width, height: size.height/6, alignment: .center)
                }
            }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        }
        
    }
}

struct TestFile_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .ignoresSafeArea()
    }
}
