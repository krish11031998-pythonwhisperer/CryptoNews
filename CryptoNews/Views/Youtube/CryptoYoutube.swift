//
//  CryptoYoutube.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 28/08/2021.
//

import SwiftUI

struct CryptoYoutube: View {
    @StateObject var VAPI:FeedAPI = .init(sources:["youtube"],type: .Chronological)
    var size:CGSize = .init()
    
    init(size:CGSize = .init(width: totalWidth, height: totalHeight)){
        self.size = size
    }
    
    func onAppear(){
        if self.VAPI.FeedData.isEmpty{
            self.VAPI.getAssetInfo()
        }
    }
    
    var videos:[AssetNewsData]{
        return self.VAPI.FeedData.compactMap({$0.url != nil && $0.url!.contains("watch") ? $0 : nil})
    }
    
    func firstVideo(size:CGSize) -> AnyView{
        guard let first = self.videos.first else {return AnyView(Color.clear.frame(width: size.width, height: size.height, alignment: .center))}
        return AnyView(VideoCard(data: first, size: size))
    }
    
    func singleCol(col:Dir,size:CGSize) -> some View{
        return VStack(alignment: .center, spacing: 10){
            ForEach(Array(self.videos[1...4].enumerated()),id:\.offset) { _video in
                let video = _video.element
                let idx = _video.offset
                
                if (col == .Left && idx%2 == 0) || (col == .Right && idx%2 == 1){
                    VideoCard(data: video, size: .init(width: size.width, height: size.height))
                }
            }
        }
    }
    
    func vGrid(size:CGSize) -> AnyView{
        let card_w = size.width * 0.5 - 5
        let card_h = size.height * 0.5 - 5
        let card_size = CGSize(width: card_w, height: card_h)
        
        let view = HStack(alignment: .center, spacing: 10){
            self.singleCol(col: .Left, size: card_size)
            self.singleCol(col: .Right, size: card_size)
        }
//        let view = LazyVGrid(columns: [GridItem(.adaptive(minimum: card_w, maximum: card_w))], alignment: .center, spacing: 10){
//            ForEach(Array(self.videos[1...4].enumerated()),id:\.offset) { _video in
//                let video = _video.element
//
//                VideoCard(data: video, size: card_size)
//            }
//
//        }
        
        return AnyView(view)
    }
    
    
    var body: some View {
        Container(heading: "Top Videos", innerView: { w in
            return GeometryReader{g in
                let size = g.frame(in: .local).size
                VStack(alignment: .center, spacing: 10){
                    if self.videos.isEmpty{
                        ProgressView()
                    }else{
                        self.firstVideo(size: .init(width: size.width, height: size.height * 0.4 - 10))
                        self.vGrid(size: .init(width: size.width, height: size.height * 0.6))
                    }
                }.frame(width: size.width, height: size.height, alignment: .center)
            }
            .frame(width: w, height: size.height , alignment: .center)
        })
        .onAppear(perform: self.onAppear)
    }
}

struct CryptoYoutube_Previews: PreviewProvider {
    static var previews: some View {
        CryptoYoutube()
            .background(Color.black)
    }
}
