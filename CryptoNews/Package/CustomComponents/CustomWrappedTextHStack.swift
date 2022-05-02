//
//  CustomWrappedHStack.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/03/2022.
//

import SwiftUI

struct CustomWrappedTextHStack: View {
    
    var data:[String]
    var width:CGFloat
    var fontSize:CGFloat
    var fontColor:Color
    var fontWeight:Font.Weight
    var padding:CGFloat
    var borderColor:Color
    var clipping:Clipping
    var background:Color
    var widthPadding:CGFloat
    var onTap:((String) -> Void)?
    
    init(
        data:[String],
        width:CGFloat = totalWidth,
        fontSize:CGFloat = 15,
        fontColor:Color = .white,
        fontWeight:Font.Weight = .medium,
        padding:CGFloat = 10,
        borderColor:Color = .black,
        clipping:Clipping = .roundCornerMedium,
        background:Color = .clear,
        widthPadding:CGFloat = 15,
        onTapHandle:((String) -> Void)? = nil
    ){
        self.width = width
        self.data = data
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.fontWeight = fontWeight
        self.padding = padding
        self.borderColor = borderColor
        self.clipping = clipping
        self.background = background
        self.widthPadding = widthPadding
        self.onTap = onTapHandle
    }
    
    @ViewBuilder func TextBubbleView(text:String) -> some View{
        let view = MainText(content: text, fontSize: self.fontSize, color: self.fontColor, fontWeight: self.fontWeight,addBG: true, padding: self.padding)
            .basicCard(background:self.background.anyViewWrapper())
            .borderCard(color: self.borderColor, clipping: self.clipping)
        if let safeHandler = self.onTap{
            view
                .buttonify{
                    safeHandler(text)
                }
        }else{
            view
        }
    }
    
    var body: some View {
        Container(width:self.width,ignoreSides: true,horizontalPadding: 0, verticalPadding: 0, lazyLoad: true){ _ in
            ForEach(Array(self.mutateData(targetWidth: self.width).enumerated()),id:\.offset){ _row in
                let row = _row.element
                HStack(alignment: .center, spacing: 10) {
                    ForEach(row, id:\.self) { rowVal in
                        self.TextBubbleView(text: rowVal)
                    }
                }
            }
        }
    }
}

extension CustomWrappedTextHStack{
    
    func mutateData(targetWidth:CGFloat) -> [[String]]{
        
        var temp:[String] = .init()
        var result:[[String]] = .init()
        var width:CGFloat = .zero
        
        for word in self.data{
            let label = UILabel()
            label.text = word
            
            label.sizeToFit()
            
            let labelwidth = (label.attributedText?.size().width ?? label.frame.size.width) + self.fontSize * 2
            
            if (width + labelwidth) < targetWidth{
                width += labelwidth
                temp.append(word)
            }else{
                width = labelwidth
                result.append(temp)
                temp.removeAll()
                temp.append(word)
            }
        }
        
        result.append(temp)
        return result

    }
}

struct CustomWrappedHStack_Previews: PreviewProvider {
    static var previews: some View {
        CustomWrappedTextHStack(data: ["BTC","AVAX","LTC","SAND","KLAY","THETA","XTZ"], width: totalWidth - 50,widthPadding: 25)
            .background(Color.AppBGColor.ignoresSafeArea())
    }
}
