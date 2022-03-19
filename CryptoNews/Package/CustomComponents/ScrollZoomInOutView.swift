//
//  CardSlidingView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 27/08/2021.
//

import SwiftUI
import Combine

public class CentralizePreference:PreferenceKey{
    public static var defaultValue: Bool = false
    
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

public struct ScrollZoomInOutView: View {
    var cardSize:CGSize
    var views:Array<AnyView>
    @State var idx:Int = -1
    @StateObject var scrollViewHelper = ScrollViewHelper()
    var centralize:Bool = false
    var leading:Bool
    
    public init(cardSize:CGSize = CardSize.slender,views:Array<AnyView>,leading:Bool = true,centralize:Bool = false){
        self.cardSize = cardSize
        self.views = views
        self.leading = leading
        self.centralize = centralize
    }

    @ViewBuilder func viewGen(view:AnyView,idx:Int,scrollProxy:ScrollViewProxy? = nil) -> some View{
        if self.centralize{
            view
                .id(idx)
                .slideZoomInOut(cardSize:cardSize, centralize: self.centralize)
                .onPreferenceChange(CentralizePreference.self) { val in
                    if val{
                        DispatchQueue.main.async {
                            self.idx = idx
                        }
                    }
                }
        }else{
            view
                .id(idx)
                .slideZoomInOut(cardSize:cardSize, centralize: self.centralize)
        }
    }
    
    var halfCardWidth:CGFloat{
        return (totalWidth - self.cardSize.width) * 0.5
    }
    
    func mainScrollBody(scrollProxy:ScrollViewProxy? = nil) -> some View{
        HStack(alignment: .center, spacing: 15){
            ForEach(Array(self.views.enumerated()),id: \.offset){ _view in
                let idx = _view.offset
                let view = _view.element
                self.viewGen(view: view, idx: idx , scrollProxy: scrollProxy)
                    .padding(.leading,idx == 0 ? 15 : 0)
            }
        }
        .padding(.leading, self.leading ? halfCardWidth : 0)
        .padding(.trailing,halfCardWidth)
    }
    
    public var body: some View {
        if self.centralize{
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    self.mainScrollBody(scrollProxy: scrollProxy)
                }
            }.frame(width:totalWidth,height: cardSize.height,alignment: .leading)
        }else{
            ScrollView(.horizontal, showsIndicators: false) {
                self.mainScrollBody()
            }
        }
    }
}


class ScrollViewHelper: ObservableObject {
    
    @Published var currentOffset: CGFloat = 0
    @Published var offsetAtScrollEnd: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AnyCancellable($currentOffset
                                        .debounce(for: 0.2, scheduler: DispatchQueue.main)
                                        .dropFirst()
                                        .assign(to: \.offsetAtScrollEnd, on: self))
    }
    
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}