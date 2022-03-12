import SwiftUI



//struct CardSize{
//    static var slender = CGSize(width: totalWidth * 0.6, height: totalHeight * 0.5)
//    static var normal = CGSize(width: totalWidth * 0.5, height: totalHeight * 0.4)
//    static var medium = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.3)
//    static var small = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.2)
//    static var tiny = CGSize(width: totalWidth * 0.25, height: totalHeight * 0.2)
//}

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
