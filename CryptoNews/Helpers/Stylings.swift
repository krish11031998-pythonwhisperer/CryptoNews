import SwiftUI
import Combine
enum Clipping:CGFloat{
    case roundClipping = 20
    case squareClipping = 10
    case roundCornerMedium = 15
    case circleClipping = 50
    case clipped = 0
}


class KeyboardHeightPreference:PreferenceKey{
    
    static var defaultValue: CGFloat = .zero
    
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

class CentralizePreference:PreferenceKey{
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

func setWithAnimation(animation:Animation = .easeInOut,completion:@escaping () -> Void){
    DispatchQueue.main.async {
        withAnimation(animation) {
            completion()
        }
    }
}

struct AsyncContainerModifier:ViewModifier{
    var g:GeometryProxy? = nil
    var axis:Axis = .vertical
    var size:CGSize = .zero
    @State var showView:Bool = false
    
    init(g:GeometryProxy? = nil,axis:Axis = .vertical,size:CGSize = .zero){
        self.g = g
        self.axis = axis
        self.size = size
    }
    
    func DispatchQueueAxis(_ g:GeometryProxy){
        
        let minX = g.frame(in: .global).minX
        let minY = g.frame(in: .global).minY
        
        
        switch(self.axis){
            case .horizontal:
                DispatchQueue.main.async {
                    if !self.showView && minX < totalWidth * 1.2{
                        withAnimation(.easeInOut) {
                            self.showView.toggle()
                        }
                    }
                }
            case .vertical:
                DispatchQueue.main.async {
                    if !self.showView && minY < totalHeight * 1.5{
                        withAnimation(.easeInOut) {
                            self.showView.toggle()
                        }
                    }
                }
            default:
                break
        }
    }
    
    init(g:GeometryProxy? = nil,size:CGSize = .zero){
        self.size = size
        self.g = g
    }

    
    @ViewBuilder var progressView:some View{
        GeometryReader { g -> AnyView in
            self.DispatchQueueAxis(g)
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 25, alignment: .center))
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
    func body(content: Content) -> some View {
        if self.showView{
            content
        }else{
            self.progressView
        }
    }
    
}

struct SlidingZoomInOut:ViewModifier{
    var g:GeometryProxy? = nil
    var cardSize:CGSize
    var centralize:Bool
    @State var centralize_container:Bool = false
    init(g:GeometryProxy? = nil,cardSize:CGSize,centralize:Bool){
        self.g = g
        self.cardSize = cardSize
        self.centralize = centralize
    }
    
    func scaleGen(g:GeometryProxy) -> CGFloat{
        let midX = g.frame(in: .global).midX
        let diff = abs(midX - (totalWidth * 0.5))/totalWidth
        let diff_percent = (diff > 0.25 ? 1 : diff/0.25)
        let scale = 1 - 0.075 * diff_percent
        if self.centralize{
            self.computeCenter(g: g)
        }
        return scale
    }
    
    func computeCenter(g:GeometryProxy){
        let midX = g.frame(in: .global).midX
        let diff = midX - totalWidth * 0.5
        if abs(diff) <= cardSize.width * 0.5{
            DispatchQueue.main.async {
                self.centralize_container = true
            }
        }
    }
    
    @ViewBuilder func mainBody(content: Content) -> some View{
        if let g = self.g{
            let scale = self.scaleGen(g: g)
            content.scaleEffect(scale)
        }else{
            GeometryReader{g -> AnyView in
                let scale = self.scaleGen(g: g)
                return AnyView(content.scaleEffect(scale))
            }.frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .center)
        }
    }
    
    func body(content: Content) -> some View {
        if self.centralize{
            self.mainBody(content: content)
                .preference(key: CentralizePreference.self, value: self.centralize_container)
        }else{
            self.mainBody(content: content)
        }
        
    }
    
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

struct MessageTextField:TextFieldStyle{
    
    var color:Color
    var fontSize:CGFloat
    var width:CGFloat
    var maxHeight:CGFloat
    
    init(color:Color = .white,fontSize:CGFloat = 20,width:CGFloat = totalWidth - 20,max_h:CGFloat = totalHeight * 0.35){
        self.color = color
        self.fontSize = fontSize
        self.width = width
        self.maxHeight = max_h
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .multilineTextAlignment(.leading)
                .lineLimit(10)
                .font(Font.custom(TextStyle.normal.rawValue, size: self.fontSize))
                .foregroundColor(Color.white)
                .background(Color.clear)
                .frame(width: width, alignment: .topLeading)
                .frame(maxHeight: maxHeight)
                .clipContent(clipping: .clipped)
                .labelsHidden()
        }
}


struct RefreshableView:ViewModifier{
    
    @Binding var refreshing:Bool
    @State var refresh_off:CGFloat = 0.0
    @State var pageRendered:Bool = false
    var hasToRender:Bool
    var width:CGFloat

    init(refreshing:Binding<Bool> = .constant(false),width:CGFloat,hasToRender:Bool){
        self._refreshing = refreshing
        self.width = width
        self.hasToRender = hasToRender
    }
    
    func resetOff(){
        withAnimation(.easeInOut) {
            self.refresh_off = 0
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
           }.frame(width: width, alignment: .center)
            .onChange(of: self.refreshing) { newValue in
               if !newValue{
                   self.resetOff()
               }
           }
        )
                
            
        }
    }
    
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            self.refreshableView.padding(.bottom,50)
            content
        }
        .frame(width: width, alignment: .top)
        .offset(y: -25 + self.refresh_off)
        .preference(key: RefreshPreference.self, value: self.refreshing)
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
            .padding(.bottom, keyboardHeight + 30)
            .onReceive(Publishers.keyboardHeight) { height in
                self.keyboardHeight = height
                if (height > 0 && !self.isKeyBoardOn) || (height == 0 && self.isKeyBoardOn){
                    self.isKeyBoardOn.toggle()
                }
            }
    }
}

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

struct Blob:ViewModifier{
    var color:AnyView
    var clipping:Clipping
    func body(content: Content) -> some View {
        content
            .padding(.horizontal,10)
            .padding(.vertical,10)
            .background(color)
            .clipContent(clipping: self.clipping)
            .overlay(RoundedRectangle(cornerRadius: self.clipping.rawValue).stroke(Color.mainBGColor, lineWidth: 2))
            .padding(.vertical,1.25)
            
            
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
        if self.size != .zero{
            content
                .frame(width: self.size.width, height: self.size.height, alignment: .center)
                .background(BlurView.thinDarkBlur)
                .clipContent(clipping: .roundClipping)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        }else{
            content
                .background(BlurView.thinDarkBlur)
                .clipContent(clipping: .roundClipping)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        }
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
            .animation(.easeInOut(duration: 0.5))
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            
    }
}

struct SlideInOut:ViewModifier{
    var scale:CGFloat
    func body(content: Content) -> some View {
        content
            .transition(.move(edge: .bottom))
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
    var alignment:Alignment
    var orientation:Axis
    init(heading:String,subHeading:String,headingSize:CGFloat = 10,subHeadingSize:CGFloat = 13,headingFont:TextStyle = .heading, subHeadingFont:TextStyle = .normal,headColor:Color = .gray,subHeadColor:Color = .white,orientation:Axis = .vertical,alignment:Alignment = .leading){
        self.heading = heading
        self.subHeading = subHeading
        self.headingSize = headingSize
        self.subHeadingSize = subHeadingSize
        self.headingFont = headingFont
        self.subHeadingFont = subHeadingFont
        self.headColor = headColor
        self.subHeadColor = subHeadColor
        self.orientation = orientation
        self.alignment = alignment
    }
        
    var body: some View{
        if self.orientation == .vertical{
            VStack(alignment: self.alignment.horizontal, spacing: 5) {
                MainText(content: self.heading, fontSize: self.headingSize, color: headColor, fontWeight: .semibold,style: headingFont)
                    .lineLimit(1)
                MainText(content: self.subHeading, fontSize: self.subHeadingSize, color: subHeadColor, fontWeight: .semibold,style: subHeadingFont)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }else if self.orientation == .horizontal{
            HStack(alignment: self.alignment.vertical, spacing: 5) {
                MainText(content: self.heading, fontSize: self.headingSize, color: headColor, fontWeight: .semibold,style: headingFont)
                    .lineLimit(1)
                MainText(content: self.subHeading, fontSize: self.subHeadingSize, color: subHeadColor, fontWeight: .semibold,style: subHeadingFont)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
}


struct TabButton:View{
    var size:CGSize
    var title:String
    var color:Color
    var fontSize:CGFloat
    var action:() -> Void
    var flexible:Bool
    
    init(width:CGFloat = totalWidth - 40, height:CGFloat = 50,title:String = "Button",fontSize:CGFloat = 15,textColor:Color = .white,flexible:Bool = false,action:@escaping () -> Void){
        self.size = .init(width: width, height: height)
        self.title = title
        self.color = textColor
        self.fontSize = fontSize
        self.flexible = flexible
        self.action = action
    }
    
    var flexibleView:some View{
        MainText(content: self.title, fontSize: self.fontSize, color: self.color, fontWeight: .semibold)
            .blobify(color: AnyView(BlurView.thinDarkBlur), clipping: .roundCornerMedium)
            .buttonify(handler: self.action)
    }
    
    var nonFlexibleView:some View{
        ZStack(alignment: .center) {
            Color.clear
            MainText(content: self.title, fontSize: 15, color: self.color, fontWeight: .semibold)
        }
        .blobify(color: AnyView(BlurView.thinDarkBlur), clipping: .roundCornerMedium)
        .frame(width: size.width, height: size.height, alignment: .center)
        .buttonify(handler: self.action)
    }
    
    var body: some View{
        if self.flexible{
            self.flexibleView
        }else{
            self.nonFlexibleView
        }
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
    
    func asyncContainer(g:GeometryProxy? = nil,axis:Axis = .vertical,size:CGSize = .zero) -> some View{
        self.modifier(AsyncContainerModifier(g: g, axis: axis, size: size))
    }
    
    func slideZoomInOut(g:GeometryProxy? = nil,cardSize:CGSize,centralize:Bool = false) -> some View{
        self.modifier(SlidingZoomInOut(g: g,cardSize: cardSize,centralize:centralize))
    }
    
    func slideRightLeft() -> some View{
        self.transition(.slideRightLeft)
    }
    
    func slideInOut() -> some View{
        self.transition(.slideInOut)
    }
    
    func blobify(color:AnyView = AnyView(Color.clear),clipping:Clipping = .squareClipping) -> some View{
        self.modifier(Blob(color: color,clipping: clipping))
    }
    
    func coloredTextField(color:Color,size:CGFloat = 50,width:CGFloat = 100,rightViewTxt:String? = nil) -> some View{
        AnyView(self.textFieldStyle(ColoredTextField(color: color,fontSize: size))
                        .aspectRatio(contentMode:.fit)
                        .frame(width: width, alignment: .topLeading)
                        .truncationMode(.tail)
                        .keyboardType(.numberPad)
        )
    }
    
    func messageTextField(fontSize:CGFloat = 20,color:Color = .white,width:CGFloat = totalWidth - 20,max_h:CGFloat = totalHeight * 0.35) -> some View{
        self.textFieldStyle(MessageTextField(color: color,fontSize: fontSize,width: width,max_h: max_h))
    }
    
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
    
    
    func basicCard(size:CGSize) -> some View{
        self.modifier(BasicCard(size: size))
    }

    func refreshableView(refreshing:Binding<Bool> = .constant(false),width:CGFloat,hasToRender:Bool) -> some View{
        self.modifier(RefreshableView(refreshing: refreshing,width: width,hasToRender: hasToRender))
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
    
    static var thinDarkBlur:BlurView = .init(style: .systemUltraThinMaterialDark)
    static var regularBlur:BlurView = .init(style: .regular)
    static var thinLightBlur:BlurView = .init(style: .systemUltraThinMaterialLight)
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

//struct Stylings_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack{
//            AnimatedWaves(image: UIImage(named: "NightLifeStockImage")!, offset: 0.15)
//
//            Spacer()
//        }.edgesIgnoringSafeArea(.all)
//
//    }
//}

