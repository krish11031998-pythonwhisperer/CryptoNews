import SwiftUI
import Combine


//public struct MessageTextField:TextFieldStyle{
//
//    var color:Color
//    var fontSize:CGFloat
//    var width:CGFloat
//    var maxHeight:CGFloat
//
//    public init(color:Color = .white,fontSize:CGFloat = 20,width:CGFloat = totalWidth - 20,max_h:CGFloat = totalHeight * 0.35){
//        self.color = color
//        self.fontSize = fontSize
//        self.width = width
//        self.maxHeight = max_h
//    }
//
//    public func _body(configuration: TextField<Self._Label>) -> some View {
//            configuration
//                .multilineTextAlignment(.leading)
//                .lineLimit(10)
//                .font(Font.custom(TextStyle.normal.rawValue, size: self.fontSize))
//                .foregroundColor(Color.white)
//                .background(Color.clear)
//                .frame(width: width, alignment: .topLeading)
//                .frame(maxHeight: maxHeight)
//                .clipContent(clipping: .clipped)
//                .labelsHidden()
//        }
//}


struct KeyboardAdaptiveValue:ViewModifier{
    @Binding var keyboardHeight:CGFloat
    
    init(keyboardHeight:Binding<CGFloat>){
        self._keyboardHeight = keyboardHeight
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(Publishers.keyboardHeight) { height in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        if self.keyboardHeight != height{
                            self.keyboardHeight = height
                        }
                    }
                }
            }
    }
}




extension View{
//    func messageTextField(fontSize:CGFloat = 20,color:Color = .white,width:CGFloat = totalWidth - 20,max_h:CGFloat = totalHeight * 0.35) -> some View{
//        self.textFieldStyle(MessageTextField(color: color,fontSize: fontSize,width: width,max_h: max_h))
//    }
    
    func keyboardAdaptive(isKeyBoardOn:Binding<Bool>? = nil) -> some View{
        self.modifier(KeyboardAdaptive(isKeyBoardOn: isKeyBoardOn))
    }
    
    func keyboardAdaptiveValue(keyboardHeight:Binding<CGFloat>) -> some View{
        self.modifier(KeyboardAdaptiveValue(keyboardHeight: keyboardHeight))
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
