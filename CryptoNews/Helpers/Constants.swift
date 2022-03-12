import SwiftUI

var mainBGView: some View {
    ZStack(alignment: .top){
        Color.black
        Color.AppBGColor.frame(width: totalWidth, height: 50)
        BlurView(style: .dark)
    }
}

var mainLightBGView:some View{
    ZStack(alignment: .bottom){
        Color.white
        Color.mainBGColor.frame(height: 50, alignment: .center)
        BlurView(style: .light)
    }
}

var baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

func wideText(width w: CGFloat,text: String, fontSize: CGFloat, color: Color = .black, fontWeight: Font.Weight = .regular, style:TextStyle = .normal) -> some View{
    return HStack{
        MainText(content: text, fontSize: fontSize, color: color, fontWeight: fontWeight, style: style)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
            .padding()
            .multilineTextAlignment(.leading)
            
        Spacer()
    }.padding(10).frame(width: w)
}



enum Dir{
    case Right
    case Left
}
