import SwiftUI

enum TextStyle:String{
    case heading = "Avenir"
//    case normal = "NixieOne-Regular"
//    case normal = "Cochin"
    case normal = "Avenir Next"
//    case normal = "Forum-Regular"
    case monospaced = ""
}

struct CardSize{
    static var slender = CGSize(width: totalWidth * 0.6, height: totalHeight * 0.5)
    static var normal = CGSize(width: totalWidth * 0.5, height: totalHeight * 0.4)
    static var medium = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.3)
    static var small = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.2)
    static var tiny = CGSize(width: totalWidth * 0.25, height: totalHeight * 0.2)
}

struct BasicText: View {
    
    var content:String
    var fontDesign:Font.Design
    var size:CGFloat
    var weight:Font.Weight
    
    
    init(content:String,fontDesign:Font.Design = .default,size:CGFloat = 15, weight:Font.Weight = .regular){
        self.content = content
        self.fontDesign = fontDesign
        self.size = size
        self.weight = weight
        
    }
    
    var body:some View{
        
        Text(self.content)
            .font(.system(size: self.size, weight: self.weight, design: self.fontDesign))
//            .foregroundColor(.black)
    }

}

struct MainText: View {
    var content:String
    var fontSize:CGFloat
    var color:Color
    var font:Font
    var fontWeight:Font.Weight
    var style:TextStyle
    var addBG:Bool
    var padding:CGFloat
    init(content:String,fontSize:CGFloat,color:Color = .white, fontWeight:Font.Weight = .thin,style:TextStyle = .normal,addBG:Bool = false,padding:CGFloat = 10){
        self.content = content.stripSpaces().removeEndLine()
        self.fontSize = fontSize
        self.color = color
        self.style = style
        self.font = .custom(self.style.rawValue, size: self.fontSize)
        self.fontWeight = fontWeight
        self.addBG = addBG
        self.padding = padding
    }
    
    struct CustomFontModifier:ViewModifier{
        var addBG:Bool
        var oppColor:Color
        var padding:CGFloat
        func body(content: Content) -> some View {
            content
                .padding(.all,addBG ? self.padding : 0)
                .background(addBG ? self.oppColor : .clear)
                .clipShape(RoundedRectangle(cornerRadius: addBG ? 20 : 0))
        }
        
    }
    
    var oppColor:Color{
        return self.color == .black ? .white : .black
    }
    
    var _font_:Font{
        return self.style != .monospaced ? .custom(self.style.rawValue, size: self.fontSize) : Font.system(size: self.fontSize, weight: .regular, design: .monospaced)
    }
    
    var body: some View {
        Text(self.content)
            .font(_font_)
            .fontWeight(self.fontWeight)
            .foregroundColor(self.color)
            .modifier(CustomFontModifier(addBG: addBG, oppColor: oppColor,padding: self.padding))
    }
}


struct HeadingInfoText:View{
    var heading:String
    var headingSize:CGFloat
    var headingColor:Color
    var subhead:String
    var subheadSize:CGFloat
    var subheadColor:Color
    var headingDesign:Font.Design
    var subheadDesign:Font.Design
    var haveBG:Bool = false
    
    init(heading:String,subhead:String, headingSize:CGFloat = 15,headingColor:Color = .white, headingDesign:Font.Design = .serif, subheadSize:CGFloat = 18,subheadColor:Color = .white,subheadDesign:Font.Design = .default,haveBG:Bool = false){
        self.heading = heading
        self.subhead = subhead
        self.headingSize = headingSize
        self.headingColor = headingColor
        self.subheadSize = subheadSize
        self.subheadColor = subheadColor
        self.headingDesign = headingDesign
        self.subheadDesign = subheadDesign
        self.haveBG = haveBG
    }
    
    func oppColor(color:Color) -> Color{
        return color == .black ? .white : .black
    }
    
    func infoText() -> some View{
        return VStack(alignment: .leading, spacing:0){
            Text(self.heading)
//                .font(.headline)
                .font(.system(size: self.headingSize, weight: .bold, design: self.headingDesign))
                .foregroundColor(self.headingColor)
                .fontWeight(.bold)
//                .aspectRatio(contentMode: .fill)
                .fixedSize(horizontal: false, vertical: true)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.headingColor) : .clear)
            Text(self.subhead)
                .font(.system(size: self.subheadSize, weight: .semibold, design: self.subheadDesign))
                .foregroundColor(self.subheadColor)
                .fontWeight(.bold)
//                .aspectRatio(contentMode: .fill)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.subheadColor) : .clear)
        }
    }

    var body: some View{
        self.infoText()
    }
    
}

struct SizeDataPreferenceKey: PreferenceKey{
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value:inout CGSize, nextValue: () -> CGSize){
        value = nextValue()
    }
}


extension View{
    
    func sizePreferenceKey(_ data:CGSize) -> some View{
        self.preference(key: SizeDataPreferenceKey.self, value: data)
    }
    
}


struct PriceCardDataPreferenceKey: PreferenceKey{
    static var defaultValue: AssetData = .init()
    
    static func reduce(value: inout AssetData, nextValue: () -> AssetData) {
        value = nextValue()
    }
}
