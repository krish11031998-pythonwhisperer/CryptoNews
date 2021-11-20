import SwiftUI
import Combine
enum Clipping:CGFloat{
    case roundClipping = 20
    case squareClipping = 10
    case roundCornerMedium = 15
    case circleClipping = 50
    case clipped = 0
}


struct ColoredTextField:TextFieldStyle{
    var color:Color
    var fontSize:CGFloat = 25
    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(Font.system(size: self.fontSize, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
                .background(Color.clear)
                .clipContent(clipping: .clipped)
                .labelsHidden()
        }
}


struct RefreshableView:ViewModifier{
    
    @State var refreshing:Bool = false
    @State var refresh_off:CGFloat = 0.0
    @State var pageRendered:Bool = false
    var hasToRender:Bool
    var width:CGFloat
    var refreshFn:((@escaping () -> Void) -> Void)
    
    
    init(width:CGFloat,hasToRender:Bool,refreshFn: @escaping (( @escaping () -> Void) -> Void)){
        self.width = width
        self.refreshFn = refreshFn
        self.hasToRender = hasToRender
    }
    
    func resetOff(){
        withAnimation(.easeInOut) {
            self.refresh_off = 0
            self.refreshing = false
        }
    }
    
    func refresh(minY:CGFloat){
        print("Refreshing.....")
        withAnimation(.easeInOut) {
            self.refreshing = true
            self.refresh_off = 100
            self.pageRendered = false
            print("DEBUG Refresh was toggled!")
        }
        self.refreshFn(self.resetOff)
    }
    
    var refreshState:Bool{
        return !self.refreshing && self.refresh_off == 0 && self.pageRendered
    }
    
    var refreshableView:some View{
        GeometryReader{g -> AnyView in
            let minY = g.frame(in: .global).minY
            DispatchQueue.main.async {
                if self.hasToRender{
                    if !self.pageRendered && minY < 0{
                        self.pageRendered = true
                    }else if minY >= 100  && self.refreshState{
                        self.refresh(minY: minY)
                    }
                }
            }
            
           return AnyView(ZStack(alignment: .center) {
                if refreshing{
                    ProgressView()
                }else{
                    SystemButton(b_name: "arrow.down", b_content: "", color: .white, haveBG: false,bgcolor: .clear) {}
                }
           }.frame(width: width, alignment: .center))
            
        }.frame(width: width, alignment: .center)
    }
    
    
    func body(content: Content) -> some View {
        return VStack(alignment: .leading, spacing: 10) {
            self.refreshableView.padding(.bottom,50)
            content
        }
        .frame(width: width, alignment: .top)
        .offset(y: -25 + self.refresh_off)
    }
}


extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct KeyboardAdaptive:ViewModifier{
    @State var keyboardHeight:CGFloat = 0
    @Binding var isKeyBoardOn:Bool
    
    init(isKeyBoardOn:Binding<Bool>? = nil){
        self._isKeyBoardOn = isKeyBoardOn ?? .constant(false)
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { height in
                self.keyboardHeight = height
                if (height > 0 && !self.isKeyBoardOn) || (height == 0 && self.isKeyBoardOn){
                    self.isKeyBoardOn.toggle()
                }
            }
    }
}


struct SystemButtonModifier:ViewModifier{
    var bg:AnyView
    var size:CGSize
    var color:Color
    init(size:CGSize,color:Color,@ViewBuilder bg:() -> AnyView){
        self.size = size
        self.color = color
        self.bg = bg()
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: self.size.width, height: self.size.height, alignment: .center)
            .foregroundColor(color)
            .padding(10)
            .background(bg)
            .clipShape(Circle())
            .contentShape(Rectangle())
    }
}

struct SpringButton:ViewModifier{
    var handleTap:(() -> Void)
    
    init(handleTap: @escaping (() -> Void)){
        self.handleTap = handleTap
    }
    
    func body(content: Content) -> some View {
        Button {
            self.handleTap()
        } label: {
            content
                .contentShape(Rectangle())
        }.springButton()
    }
}

struct Blob:ViewModifier{
    var color:Color
    
    @ViewBuilder var bg:some View{
        if self.color == .clear{
            BlurView(style: .systemThinMaterialDark)
        }else{
            self.color
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal,10)
            .padding(.vertical,10)
            .background(bg)
            .clipContent(clipping: .squareClipping)
    }
}

struct ContentClipping:ViewModifier{
    var clipping:Clipping

    func body(content: Content) -> some View {
        if self.clipping == .circleClipping{
            content
                .contentShape(Circle())
                .clipShape(Circle())
        }else{
            content
                .contentShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
                .clipShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
        }
    }
}


struct BasicCard:ViewModifier{
    var size:CGSize
    func body(content: Content) -> some View {
        if self.size.height != 0{
            content
                .padding()
                .frame(width: self.size.width, height: self.size.height, alignment: .center)
                .background(BlurView(style: .systemThinMaterialDark))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        }else{
            content
                .padding()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.size.width, alignment: .center)
                .background(BlurView(style: .systemThinMaterialDark))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        }
//        content
//            .padding()
//            .frame(width: self.size.width, height: self.size.height, alignment: .center)
//            .background(BlurView(style: .systemThinMaterialDark))
//            .cornerRadius(20)
//            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

struct ImageTransition:ViewModifier{
    @State var load:Bool = false
    
    func onAppear(){
        withAnimation(.easeInOut(duration: 0.5)) {
            self.load = true
        }
    }
    
    var scale:CGFloat{
        return self.load ? 1 : 1.075
    }
    
    func body(content: Content) -> some View {
        return content
            .scaleEffect(self.scale)
            .onAppear(perform: self.onAppear)
    }
}

struct ShadowModifier:ViewModifier{
    func body(content: Content) -> some View {
        content
            .shadow(color: .white.opacity(0.05), radius: 10, x: 0, y: 0)
    }
}

struct ZoomInOut:ViewModifier{
    
    @State var scale:CGFloat = 1.2
    @State var opacity:CGFloat = 0.8
    
    func onAppear(){
        withAnimation(.easeInOut) {
            self.scale = 1
            self.opacity = 1
        }
    }
    
    func onDisappear(){
        withAnimation(.easeInOut) {
            self.scale = 0.75
            self.opacity = 0.75
        }
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            .animation(.easeInOut(duration: 0.5))
    }
}

struct SlideInOut:ViewModifier{
    var scale:CGFloat
    func body(content: Content) -> some View {
        content
            .transition(.move(edge: .bottom))
            .animation(.easeInOut)
    }
}

struct MainSubHeading:View{
    var heading:String
    var subHeading:String
    var headingSize:CGFloat
    var subHeadingSize:CGFloat
    var headingFont:TextStyle
    var subHeadingFont:TextStyle
    var headColor:Color
    var subHeadColor:Color
    var alignment:HorizontalAlignment
    init(heading:String,subHeading:String,headingSize:CGFloat = 10,subHeadingSize:CGFloat = 13,headingFont:TextStyle = .heading, subHeadingFont:TextStyle = .normal,headColor:Color = .gray,subHeadColor:Color = .white,alignment:HorizontalAlignment = .leading){
        self.heading = heading
        self.subHeading = subHeading
        self.headingSize = headingSize
        self.subHeadingSize = subHeadingSize
        self.headingFont = headingFont
        self.subHeadingFont = subHeadingFont
        self.headColor = headColor
        self.subHeadColor = subHeadColor
        self.alignment = alignment
    }
    
    var body: some View{
        VStack(alignment: alignment, spacing: 5) {
            MainText(content: self.heading, fontSize: self.headingSize, color: headColor, fontWeight: .semibold,style: headingFont)
                .lineLimit(1)
            MainText(content: self.subHeading, fontSize: self.subHeadingSize, color: subHeadColor, fontWeight: .semibold,style: subHeadingFont)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
}


struct TabButton:View{
    var size:CGSize
    var title:String
    var color:Color
    var action:() -> Void
    
    init(width:CGFloat = totalWidth - 40, height:CGFloat = 50,title:String = "Button",textColor:Color = .white,action:@escaping () -> Void){
        self.size = .init(width: width, height: height)
        self.title = title
        self.color = textColor
        self.action = action
    }
    
    
    var body: some View{
        ZStack(alignment: .center) {
            BlurView(style: .regular)
            MainText(content: self.title, fontSize: 15, color: self.color, fontWeight: .semibold)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipContent(clipping: .roundClipping)
        .defaultShadow()
        .onTapGesture(perform: self.action)
    }
    
}


struct ButtonModifier:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}


extension AnyTransition{
    
    static var slideInOut:AnyTransition{
        return AnyTransition.asymmetric(insertion:.move(edge: .bottom), removal: .move(edge: .bottom))
    }
    
    static var zoomInOut:AnyTransition{
        return AnyTransition.asymmetric(insertion: .scale(scale: 1.5).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)).animation(.easeInOut)
    }

    static var slideRightLeft:AnyTransition{
        return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }
    
}


extension View{
    func springButton() -> some View{
        self.buttonStyle(ButtonModifier())
    }
    
    func clipContent(clipping:Clipping = .clipped) -> some View{
        self.modifier(ContentClipping(clipping: clipping))
    }
    
    func defaultShadow() -> some View{
        self.modifier(ShadowModifier())
    }
    
    func imageSpring() -> some View{
        self.modifier(ImageTransition())
    }
    
    func zoomInOut() -> some View{
        self.modifier(ZoomInOut())
    }
    
    func slideRightLeft() -> some View{
        self.transition(.slideRightLeft)
    }
    
    func slideInOut() -> some View{
        self.transition(.slideInOut)
    }
    
    func blobify(color:Color = .clear) -> some View{
        self.modifier(Blob(color: color))
    }
    
    func buttonify(handler:@escaping (() -> Void)) -> some View{
        self.modifier(SpringButton(handleTap: handler))
    }
    
    func coloredTextField(color:Color,size:CGFloat = 50,maxWidth:CGFloat = 100,rightViewTxt:String? = nil) -> AnyView{
        if let rightViewTxt = rightViewTxt {
            return AnyView(HStack(alignment: .firstTextBaseline, spacing: 5) {
                self.textFieldStyle(ColoredTextField(color: color,fontSize: size))
                    .multilineTextAlignment(.trailing)
                    .aspectRatio(contentMode:.fit)
                    .frame(idealWidth:20,maxWidth: 100,alignment: .center)
                    .keyboardType(.decimalPad)

                MainText(content: rightViewTxt, fontSize: 13, color: .white, fontWeight: .bold, style: .monospaced)
            }.frame(alignment: .top))
        }
        return AnyView(self.textFieldStyle(ColoredTextField(color: color,fontSize: size))
                        .multilineTextAlignment(.trailing)
                        .aspectRatio(contentMode:.fit)
                        .frame(idealWidth:20,maxWidth: 100,alignment: .center)
                        .keyboardType(.numberPad)
        )
    }
    
    func keyboardAdaptive(isKeyBoardOn:Binding<Bool>? = nil) -> some View{
        self.modifier(KeyboardAdaptive(isKeyBoardOn: isKeyBoardOn))
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    
    func basicCard(size:CGSize) -> some View{
        self.modifier(BasicCard(size: size))
    }
    
    
    func refreshableView(width:CGFloat,hasToRender:Bool,refreshFn: @escaping ((@escaping () -> Void) -> Void)) -> some View{
        self.modifier(RefreshableView(width: width,hasToRender: hasToRender, refreshFn: refreshFn))
    }
    
    func systemButtonModifier(size:CGSize,color:Color,@ViewBuilder bg: () -> AnyView) -> some View{
        self.modifier(SystemButtonModifier(size: size, color: color, bg: bg))
    }
    
    
}

struct Corners:Shape{
    
    var rectCorners:UIRectCorner
    var size:CGSize
    init(rect:UIRectCorner,size:CGSize? = nil){
        self.rectCorners = rect
        if let safeSize = size{
            self.size = safeSize
        }else{
            self.size = CGSize(width: 50, height: 50)
        }
    }
    func path(in rect: CGRect) -> Path {
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: self.rectCorners, cornerRadii: self.size).cgPath)
//        return Path(
    }
    
    
}

struct Wave:Shape{
    var offset:CGFloat = 0.5
    var animatableData: CGFloat{
        get{
            return self.offset
        }
        set{
            self.offset = newValue
        }
    }
    
    func curveHeight(value:CGFloat,factor:CGFloat) -> CGFloat{
        let finalValue = value * factor
//        return finalValue > value ? value : finalValue
        return finalValue
    }
    
    func path(in rect:CGRect) -> Path{
        var path = Path()
        let maxH:CGFloat = rect.maxY * 0.9
        let c1H = self.curveHeight(value:maxH,factor:(1 - offset))
        let c2H = self.curveHeight(value:maxH,factor:(1 + offset))
        path.move(to: .zero)
        path.addLine(to: .init(x: rect.maxX, y: rect.minY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
//        path.addCurve(to: .init(x: rect.minX, y: rect.maxY), control1: .init(x: rect.maxX * 0.75, y: maxH * (1 - offset)), control2: .init(x: rect.maxX * 0.25, y: maxH * (1 + offset)))
        path.addCurve(to: .init(x: rect.minX, y: rect.maxY), control1: .init(x: rect.maxX * 0.75, y: c1H ), control2: .init(x: rect.maxX * 0.25, y: c2H))
        path.addLine(to: .init(x: rect.minX, y: rect.minY))
        return path
    }
}

struct AnimatedWaves:View{
    var image:UIImage = .init()
    var offset:CGFloat = 0.5
    @State private var change:Bool = false
    var aR:CGFloat?
    
    var aspectRatio:CGFloat{
        get{
            return self.aR != nil ? self.aR! : UIImage.aspectRatio(img: self.image)
        }
    }
    var changeOffset:CGFloat{
        get{
           return self.change ? offset : -offset
        }
    }
    var body: some View{
        Image(uiImage: self.image)
            .resizable()
            .frame(width:totalWidth,height: 300)
            .aspectRatio(self.aspectRatio, contentMode: .fill)
            .clipShape(Wave(offset: self.changeOffset))
            .animation(Animation.easeInOut(duration: Double(self.offset * 10)).repeatForever(autoreverses: true))
            .onAppear(perform: {
                self.change = true
            })
    }
}

struct BlurView:UIViewRepresentable{
    var style : UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: self.style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}


struct ArcCorners:Shape{
    
    var corner:UIRectCorner = .topRight
    var curveFactor:CGFloat = 0.75
    var cornerRadius:CGFloat = 45.0
    var roundedCorner:UIRectCorner = .allCorners
    
    func CornerPoint(_ rect:CGRect,_ corner:UIRectCorner) -> CGPoint{
        var point:CGPoint = .init()
        var topCorner = self.corner == corner ? rect.height * self.curveFactor : 0
        var bottomCorner = self.corner == corner ? rect.height * (1 - self.curveFactor) : rect.height
        var val = corner == .topRight || corner == .topLeft ? topCorner : bottomCorner
        switch (corner){
            case .topLeft:
                point = CGPoint(x:0 , y: val)
                break
            case .topRight:
                point = CGPoint(x:rect.width,y:val)
                break
            case .bottomLeft:
                point = CGPoint(x:0 , y: val)
                break
            case .bottomRight:
                point = CGPoint(x:rect.width,y:val)
                break
            default:
                break
        }
        
        return point
    }
    
    func curvedCorners(_ corner:UIRectCorner) -> CGFloat{
        return corner == .allCorners || self.roundedCorner.contains(corner) ? self.cornerRadius : 0
    }
    
    func path(in rect: CGRect) -> Path {
        return Path{path in
            let topRight = self.CornerPoint(rect, .topRight)
            let topLeft = self.CornerPoint(rect, .topLeft)
            let bottomLeft = self.CornerPoint(rect, .bottomLeft)
            let bottomRight = self.CornerPoint(rect, .bottomRight)
            
            switch (corner){
            case .topLeft, .bottomLeft:
                    path.move(to: topLeft)
                    break
                case .topRight , .bottomRight:
                    path.move(to: topRight)
                    break
                default:
                    break
            }
            
            path.addArc(tangent1End: topLeft, tangent2End: bottomLeft, radius: self.curvedCorners(.topLeft))
            path.addArc(tangent1End: bottomLeft, tangent2End: bottomRight, radius: self.curvedCorners(.bottomLeft))
            path.addArc(tangent1End: bottomRight, tangent2End: topRight, radius: self.curvedCorners(.bottomRight))
            path.addArc(tangent1End: topRight, tangent2End: topLeft, radius: self.curvedCorners(.topRight))
            
        }
    }
    
    
    
}

struct BarCurve:Shape{
    var tabPoint:CGFloat
    
    var animatableData: CGFloat{
        get{return self.tabPoint}
        set{
            self.tabPoint = newValue
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            let width = rect.width
            let height = rect.height
            
            path.move(to: .init(x: width, y: height))
            path.addLine(to: .init(x: width, y: 0))
            path.addLine(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 0, y: height))
            
            let mid = (width * 0.5 + self.tabPoint) - 15
            
            path.move(to: .init(x: mid - 40, y: height))
            
            let to1 = CGPoint(x: mid, y: height - 20)
            let control1 = CGPoint(x : mid - 15,y:height)
            let control2 = CGPoint(x : mid - 15,y:height - 20)
            
            
            let to2 = CGPoint(x: mid + 40, y: height)
            let control3 = CGPoint(x : mid + 15,y:height - 20)
            let control4 = CGPoint(x : mid + 15,y:height)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}


struct GradientShadows:View{
    
    var color:Color
    var mode:Color
    init(color:Color,mode:Color = .white){
        self.color = color
        self.mode = mode
    }
    
    var body: some View{
        LinearGradient(gradient: .init(colors: [self.color,self.color.opacity(0.5),self.mode]), startPoint: .topLeading, endPoint: .bottomTrailing);
    }
    
}

struct Stylings_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            AnimatedWaves(image: UIImage(named: "NightLifeStockImage")!, offset: 0.15)
            
            Spacer()
        }.edgesIgnoringSafeArea(.all)
        
    }
}

