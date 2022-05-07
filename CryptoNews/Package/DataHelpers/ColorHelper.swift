import SwiftUI

public var bottomShadow = LinearGradient(gradient: .init(colors: [.clear,.black]), startPoint: .top, endPoint: .bottom)
public var lightbottomShadow = LinearGradient(gradient: .init(colors: [.clear,Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)

public extension UIColor{
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

public extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    
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
            (a, r, g, b) = (255, 255, 255, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static var mainBGColor = Color.linearGradient()
    static var darkGradColor = LinearGradient(gradient: .init(colors: [.clear,.black]), startPoint: .top, endPoint: .bottom)
    static var cardColor = BlurView(style: .dark)
    static var primaryColor:Color = .init(UIColor(hex: "#191A1DFF") ?? .white)
    static var AppBGColor = linearGradient(colors: [Color(hex: "#253341"),Color(hex: "#15202B")], start: .top, end: .bottom)
    
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
