//
//  CryptoYoutube.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 28/08/2021.
//

import SwiftUI

struct CryptoYoutube: View {
//    @StateObject var VAPI:FeedAPI = .init(sources:["youtube"],type: .Chronological)
    @StateObject var VAPI:CrybseVideoAPI
    var size:CGSize = .init()
    
    init(q:String = "cryptocurrency",size:CGSize = .init(width: totalWidth, height: totalHeight)){
        self.size = size
        self._VAPI = .init(wrappedValue: .init(q: q))
    }
    
    func onAppear(){
        if self.VAPI.videos.isEmpty{
            self.VAPI.getVideos()
        }
    }
    
    var videos:CrybseVideosData{
        return self.VAPI.videos
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
        
        return AnyView(view)
    }
    
    var innerContainerHeight:CGFloat{
        return self.size.height * 0.75
    }
    
    var body: some View {
        Container(heading: "Top Videos",width: self.size.width,ignoreSides: false){ w in
            VStack(alignment: .center, spacing: 10){
                if self.videos.isEmpty{
                    ProgressView()
                }else{
                    self.firstVideo(size: .init(width: w, height: self.innerContainerHeight * 0.4 - 10))
                    self.vGrid(size: .init(width: w, height: self.innerContainerHeight * 0.6))
                }
            }.frame(width: w, height: self.innerContainerHeight, alignment: .center)
        }
        .frame(width: size.width, height: size.height , alignment: .center)
        .onAppear(perform: self.onAppear)
    }
}

struct CryptoYoutube_Previews: PreviewProvider {
    static var previews: some View {
        CryptoYoutube(q: "bitcoin")
            .background(Color.black.ignoresSafeArea())
    }
}
