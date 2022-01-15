import SwiftUI

var totalWidth = UIScreen.main.bounds.width
var AppWidth = totalWidth * 0.9
var totalHeight = UIScreen.main.bounds.height
extension Color{
//    static var mainBGColor = LinearGradient(gradient: .init(colors: [.pink,.red,.blue]), startPoint: .topTrailing, endPoint: .bottomLeading)
    //UIColor(hex: "#D16BA5")
    
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            }

            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    
//    static var mainBGColor = Color.linearGradient(colors: [Color(hex: "#D16BA5"),Color(hex: "#86A8E7"),Color(hex: "#5FFBF1")], start: .topTrailing, end: .bottomLeading)
    static var mainBGColor = Color.linearGradient()
    static var darkGradColor = LinearGradient(gradient: .init(colors: [.clear,.black]), startPoint: .top, endPoint: .bottom)
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
    
    static func linearGradient(colors _colors:[Any] = [],start:UnitPoint = .topLeading,end:UnitPoint = .bottomTrailing) -> LinearGradient{
        var parsedColors:[Color] = [.red,.blue]
        if !_colors.isEmpty{
            if let colors = _colors as? [Color]{
                parsedColors = colors
            }else if let colors = _colors as? [UIColor]{
                parsedColors = colors.map({Color($0)})
            }
        }
        
        return LinearGradient(gradient: .init(colors: parsedColors), startPoint: start, endPoint: end)
        
    }
}
var mainBGView: some View {
    ZStack(alignment: .top){
        Color.black
        Color.mainBGColor.frame(width: totalWidth, height: 50)
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


func convertToDecimals(value:Float?) -> String{
    guard let value = value else {return "$0"}
    let decimal = value.truncatingRemainder(dividingBy: 1) != 0 ? "%.2f" : "%.0f"
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

func convertToMoneyNumber(value:Float?) -> String{
    guard let _value = value else {return "$0"}
    let value = abs(_value)
    var result:String = ""
    let decimal = value.truncatingRemainder(dividingBy: 1) != 0 ? "%.2f" : "%.0f"
    if value > 1000 && value < 1000000{
        result = "$\(String(format: decimal, value/1000))k"
    }else if value > 1000000 && value < 1000000000{
        result =  "$\(String(format: decimal,value/1000000))M"
    }else if value > 1000000000 && value < 999999995904{
        result =  "$\(String(format: decimal,value/1000000000))B"
    }else if value >= 999999995904{
        result =  "$\(String(format: decimal,value/1000000000000))T"
    }else{
        result =  "$\(String(format: decimal,value))"
    }
    
    return _value < 0 ? "- "+result : result
}


enum Dir{
    case Right
    case Left
}
