//
//  LazyScrollView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/10/2021.
//

import SwiftUI

struct RefreshPreference:PreferenceKey{
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
    
}

public struct LazyScrollView<T:View>: View {
    var data:[Any]?
    var embedScrollView:Bool
    var axis:Axis
    var alignment:Alignment
    var viewGen: (Any) -> T
    @State var reloadNow:Bool = false
    var stopLoading:Bool
    var header:String?
    
    public init(
        header:String? = nil,
        data:[Any]? = nil,
        embedScrollView:Bool = false,
        axis:Axis = .vertical,
        alignment:Alignment = .center,
        stopLoading:Bool = false,
        @ViewBuilder viewGen: @escaping (Any) -> T
    ){
        self.header = header
        self.data = data
        self.stopLoading = stopLoading
        self.viewGen = viewGen
        self.embedScrollView = embedScrollView
        self.axis = axis
        self.alignment = alignment
    }
    
    
    var reloadContainer:some View{
        GeometryReader{g -> AnyView in
            let maxY = g.frame(in: .global).maxY
            
            DispatchQueue.main.async {
                if maxY < (totalHeight) && !self.reloadNow{
                    self.reloadNow.toggle()
                }
            }
            
            return AnyView(ProgressView().frame(width: totalWidth - 20, height: 100, alignment: .center))
        }
    }
    
    @ViewBuilder func headingTitle(heading:String) -> some View{
        VStack(alignment: .leading, spacing: 5) {
            MainText(content: heading, fontSize: 30, color: .white, fontWeight: .semibold,style: .heading)
            RoundedRectangle(cornerRadius: Clipping.roundCornerMedium.rawValue)
                .fill(Color.mainBGColor)
                .frame(height:2)
        }.aspectRatio(contentMode: .fit)
    }
    
    
    @ViewBuilder var innerBodyOfRefreshingView:some View{
        if let header = header {
            self.headingTitle(heading: header)
        }
        if let data = data {
            ForEach(Array(data.enumerated()), id:\.offset) {_data in
                let data = _data.element
                self.viewGen(data)
            }
        }else{
            self.viewGen(0)
        }
    }
    
    @ViewBuilder var refreshingView:some View{
        if self.axis == .vertical{
            LazyVStack(alignment: self.alignment.horizontal, spacing: 10) {
                self.innerBodyOfRefreshingView
            }
        }else if self.axis == .horizontal{
            LazyHStack(alignment: self.alignment.vertical, spacing: 10) {
                self.innerBodyOfRefreshingView
            }
        }
        
        
    }
        
    public var body: some View {
        if self.embedScrollView{
            ScrollView(.vertical, showsIndicators: false) {
                self.refreshingView
                    .preference(key: RefreshPreference.self, value: self.reloadNow)
                    .padding(.vertical,50)
            }
        }else{
            self.refreshingView
        }
        
    }
}
