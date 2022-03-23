//
//  MoneyTextView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 22/03/2022.
//

import SwiftUI

struct MoneyTextView: View {
    
    var size:CGFloat
    var coloredText:Bool
    var value:Float
    var fontWeight:Font.Weight
    
    
    init(value:Float,size:CGFloat = 15,fontWeight:Font.Weight = .medium,coloredText:Bool = false){
        self.value = value
        self.size = size
        self.fontWeight = fontWeight
        self.coloredText = coloredText
    }
    
    var color:Color{
        return coloredText ? value > 0 ? Color.green : value < 0 ? Color.red : Color.gray : Color.white
    }
    
    var body: some View {
        MainText(content: abs(self.value).ToPrettyMoney(), fontSize: self.size, color: self.color, fontWeight: self.fontWeight)
    }
}

//struct MoneyTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoneyTextView()
//    }
//}
