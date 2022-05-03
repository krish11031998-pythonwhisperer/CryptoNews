//
//  SwipedParams.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 27/04/2021.
//

import SwiftUI

public enum SliderType{
    case Carousel
    case Stack
}


public class swipeParams:ObservableObject,Equatable{
    public static func == (lhs: swipeParams, rhs: swipeParams) -> Bool {
        return lhs.swiped == rhs.swiped
    }
    
    var start:Int = 0
    var end:Int = 0
    var thresValue:CGFloat = 0
    var singleSide:Bool
    fileprivate var _type:SliderType = .Carousel
    var onTap: ((Int) -> Void)? = nil
    
    public init(_ start:Int? = nil,_ end:Int? = nil, _ thresValue:CGFloat? = nil,type:SliderType = .Carousel,singleSide:Bool = false,onTap:((Int) -> Void)? = nil){
        self.start = start ?? 0
        self.end = end ?? 0
        self.thresValue = thresValue ?? 100
        self._type = type
        self.onTap = onTap
        self.singleSide = singleSide
    }
    
    public var type:SliderType{
        get{
            return self._type
        }
        
        set{
            self._type = newValue
        }
    }
    
    @Published var swiped:Int = 0
    @Published var swipedID:String = ""
    @Published var extraOffset:CGFloat = 0.0
    @Published var xOffset:CGFloat = 0.0
    @Published var yOffset:CGFloat = 0.0
    
    
    public func onChanged(value:CGFloat){
        if self.swiped >= self.start || self.swiped < self.end{
            setWithAnimation {
                self.extraOffset = value
            }
        }
    }
    
    public func updateSwipe(val:Int){
        setWithAnimation {
            self.swiped += val
        }
    }
    
    public func onChanged(ges_value:DragGesture.Value){
        let value = self.type == .Carousel ? ges_value.translation.width : ges_value.translation.height
        if self.singleSide && value < 0 || !self.singleSide{
            self.onChanged(value: value)
        }
    }
    
    
    public func onEnded(value:CGFloat){
        if abs(value) > self.thresValue{
            var val:Int = 0
            switch(self._type){
                case .Carousel:
                    val = value < 0 && self.swiped < self.end ? 1 : value > 0 && self.swiped > self.start ? -1 : 0
                    break;
                case .Stack:
                    val = value < 0 && self.swiped < self.end ? 1 : value > 0 && self.swiped > self.start ? -1 : 0
            }
            self.updateSwipe(val: val)
        }
        
        setWithAnimation {
            self.extraOffset = 0
        }
    }
    
    public func onEnded(ges_value:DragGesture.Value){
        let value = self.type == .Carousel ? ges_value.translation.width : ges_value.translation.height
        if self.singleSide && value < 0 || !self.singleSide{
            self.onEnded(value: value)
        }
    }
    
    
}
