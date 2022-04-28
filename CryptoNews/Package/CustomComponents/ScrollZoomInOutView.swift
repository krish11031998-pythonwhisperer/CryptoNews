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

public struct ScrollZoomInOutView<T:View>: View {
    var cardSize:CGSize
    var cardViewGen:(Any,CGSize) -> T
    var viewsData:[Any]
    @State var idx:Int = -1
    @StateObject var scrollViewHelper = ScrollViewHelper()
    var leading:Bool
    
    public init(cardSize:CGSize = CardSize.slender,viewData:[Any],leading:Bool = true,@ViewBuilder viewGen:@escaping (Any,CGSize) -> T){
        self.cardSize = cardSize
        self.viewsData = viewData
        self.cardViewGen = viewGen
        self.leading = leading
    }
    
    var halfCardWidth:CGFloat{
        return (totalWidth - self.cardSize.width) * 0.5
    }
    
    func mainScrollBody(scrollProxy:ScrollViewProxy? = nil) -> some View{
        HStack(alignment: .center, spacing: 15){
            ForEach(Array(self.viewsData.enumerated()),id: \.offset){ _view in
                let data = _view.element
                self.cardViewGen(data, self.cardSize)
                    .slideZoomInOut(cardSize: cardSize)
            }
        }
        .padding(.leading, self.leading ? halfCardWidth : 0)
        .padding(.trailing,halfCardWidth)
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            self.mainScrollBody()
        }
    }
}


class ScrollViewHelper: ObservableObject {
    
    @Published var currentOffset: CGFloat = 0
    @Published var offsetAtScrollEnd: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AnyCancellable($currentOffset
                                        .debounce(for: 0.05, scheduler: DispatchQueue.main)
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
