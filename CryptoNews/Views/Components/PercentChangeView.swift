//
//  PercentChangeView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 17/02/2022.
//

import SwiftUI

struct PercentChangeView: View {
    var value:Float
    var type:String
    
    init(value:Float,type:String){
        self.value = value
        self.type = type
    }
    
    var img:String{
        value > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill"
    }
    
    var color:Color{
        value > 0 ? Color.green : value < 0 ? Color.red : Color.clear
    }
    
    var imgSize:CGFloat{
        type == "large" ? 15 : 10
    }
    
    var textSize:CGFloat{
        type == "large" ? 12 : 9
    }
    
    var padding:CGFloat{
        type == "large" ? 15 : 7.5
    }
    
    var percentChangeView:some View{
        let view = HStack(alignment: .center) {
            Image(systemName: self.img)
                .resizable()
                .frame(width: self.imgSize, height: self.imgSize, alignment: .center)
                .foregroundColor(.white)
            MainText(content: convertToDecimals(value: abs(self.value)) + "%", fontSize: self.textSize, color: .white, fontWeight: .bold,style: .monospaced)
        }.padding(self.padding)
        .background(self.color)
        .clipContent(clipping: .roundClipping)
        
        return view
    }

    var body: some View {
        self.percentChangeView
    }
}

struct PercentChangeView_Previews: PreviewProvider {
    static var previews: some View {
        PercentChangeView(value: 50, type: "large")
    }
}
