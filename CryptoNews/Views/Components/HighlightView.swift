//
//  HighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 19/01/2022.
//

import SwiftUI

struct HighlightView: View {
    @Binding var value:Float
    @State var color:Color = .black
    var baseColor:Color
    var fontSize:CGFloat
    
    init(value:Binding<Float>,baseColor:Color = .black,fontSize:CGFloat = 15){
        self._value = value
        self.baseColor = baseColor
        self.fontSize = fontSize
    }

    var body: some View {
        MainText(content: (self.value ?? 0).ToMoney(), fontSize: self.fontSize, color: self.color, fontWeight: .semibold)
            .onChange(of: self.value) { newPrice in
//                guard let prevValue = self.value, let safeNewPrice = newPrice else {return}
//                if prevValue < safeNewPrice{
//                    self.color = .green
//                }else if prevValue > safeNewPrice{
//                    self.color = .red
//                }
                if self.value < newPrice{
                    self.color = .green
                }else if self.value > newPrice{
                    self.color = .red
                }
            }
    }
}

//struct HighlightView_Previews: PreviewProvider {
//    static var previews: some View {
//        HighlightView()
//    }
//}
