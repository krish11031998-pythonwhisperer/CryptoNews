//
//  ShapeModifier.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 03/03/2022.
//

import SwiftUI

public struct ArcCorners:Shape{
    
    var corner:UIRectCorner
    var curveFactor:CGFloat
    var cornerRadius:CGFloat
    var roundedCorner:UIRectCorner
    
    public init(corner:UIRectCorner = .topRight,curveFactor:CGFloat = 0.75,cornerRadius:CGFloat = 45.0,roundedCorner:UIRectCorner = .allCorners){
        self.corner = corner
        self.curveFactor = curveFactor
        self.cornerRadius = cornerRadius
        self.roundedCorner = roundedCorner
    }
        
    
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
    
    public func path(in rect: CGRect) -> Path {
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


public struct Wave:Shape{
    var offset:CGFloat = 0.5
    
    public init(offset:CGFloat){
        self.offset = offset
    }
    
    public var animatableData: CGFloat{
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
    
    public func path(in rect:CGRect) -> Path{
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

public struct AnimatedWaves:View{
    var image:UIImage
    var offset:CGFloat
    @State private var change:Bool
    var aR:CGFloat?
    
    public init(image:UIImage,offset:CGFloat = 0.5,aR:CGFloat? = nil){
        self.image = image
        self.offset = offset
        self._change = .init(initialValue: false)
        self.aR = aR
    }
    
    public var aspectRatio:CGFloat{
        get{
            return self.aR != nil ? self.aR! : UIImage.aspectRatio(img: self.image)
        }
    }
    public var changeOffset:CGFloat{
        get{
           return self.change ? offset : -offset
        }
    }
    public var body: some View{
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

public struct Corners:Shape{
    
    var rectCorners:UIRectCorner
    var size:CGSize
    
    public init(rect:UIRectCorner,size:CGSize? = nil){
        self.rectCorners = rect
        if let safeSize = size{
            self.size = safeSize
        }else{
            self.size = CGSize(width: 50, height: 50)
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: self.rectCorners, cornerRadii: self.size).cgPath)
    }
}

public struct BarCurve:Shape{
    var tabPoint:CGFloat
    
    public init(tabPoint:CGFloat){
        self.tabPoint = tabPoint
    }
    
    public var animatableData: CGFloat{
        get{return self.tabPoint}
        set{
            self.tabPoint = newValue
        }
    }
    
    
    public func path(in rect: CGRect) -> Path {
        
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

