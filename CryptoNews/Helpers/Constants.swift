import SwiftUI

var totalWidth = UIScreen.main.bounds.width
var AppWidth = totalWidth * 0.9
var totalHeight = UIScreen.main.bounds.height
extension Color{
    static var mainBGColor = LinearGradient(gradient: .init(colors: [.red,.blue]), startPoint: .topTrailing, endPoint: .bottomLeading)
    static var cardColor = BlurView(style: .dark)
    static var primaryColor:Color = .init(UIColor(hex: "#191A1DFF") ?? .white)
    
    static func colorConvert(red:Double,green:Double,blue:Double) -> Color{
        let r:Double = red/255.0
        let g:Double = green/255.0
        let b:Double = blue/255.0
        return .init(red: r, green: g, blue: b)
    }
    static var mainBG:Color = Color.colorConvert(red: 250, green: 251, blue: 245)
    static func cardBGColor(size:CGSize) -> AnyView{
        return AnyView(ZStack(alignment: .bottom) {
            Color.mainBGColor.frame(width: size.width, height: size.height * 0.1, alignment: .center)
            BlurView(style: .light)
        })
    }
    
    static func linearGradient(colorOne:UIColor,colorTwo:UIColor) -> LinearGradient{
        return LinearGradient(gradient: .init(colors: [Color(colorOne),Color(colorTwo)]), startPoint: .top, endPoint: .bottom)
    }
}
var mainBGView: some View {
    ZStack(alignment: .top){
        Color.black
        Color.mainBGColor.frame(width: totalWidth, height: totalHeight * 0.25)
        BlurView(style: .dark)
        
    }
}
var baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
var bottomShadow = LinearGradient(gradient: .init(colors: [.clear,.black]), startPoint: .top, endPoint: .bottom)
var lightbottomShadow = LinearGradient(gradient: .init(colors: [.clear,Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)

func overlayShadows(width w:CGFloat,height h:CGFloat) -> some View{
    return VStack{
        Image.topShadow
            .resizable()
            .frame(width: w)
            .aspectRatio(contentMode: .fit)
            .frame(minHeight:h*0.25)
        Spacer(minLength: h * 0.5)
        Image.bottomShadow
            .resizable()
            .frame(width: w)
            .aspectRatio(contentMode: .fit)
            .frame(minHeight:h*0.25)
    }.edgesIgnoringSafeArea(.all).frame(height:h)
}

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

func convertToMoneyNumber(value:Float?) -> String{
    guard let value = value else {return "No Value"}
    let decimal = value.truncatingRemainder(dividingBy: 1) != 0 ? "%.1f" : "%.0f"
    if value > 1000 && value < 1000000{
        return "\(String(format: decimal, value/1000))k"
    }else if value > 1000000 && value < 1000000000{
        return "\(String(format: decimal,value/1000000))M"
    }else if value > 1000000000{
        return "\(String(format: decimal,value/1000000000))B"
    }else{
        return "\(String(format: decimal,value))"
    }
}


enum Dir{
    case Right
    case Left
}
