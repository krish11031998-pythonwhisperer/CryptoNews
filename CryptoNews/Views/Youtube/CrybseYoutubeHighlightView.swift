//
//  CrybseYoutubeHighlightView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 13/02/2022.
//

import SwiftUI

struct CrybseYoutubeHighlightView: View {
    
    var currencies:[String]
    var width:CGFloat
    @StateObject var VAPI:CrybseVideoAPI
    
    init(currencies:[String] = ["cryptocurrency"],width:CGFloat){
        self.currencies = currencies
        self._VAPI = .init(wrappedValue: .init(q: currencies.reduce("", {$0 == "" ? $1 : $0+","+$1})))
        self.width = width
    }
    
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) {
            if self.VAPI.videos.isEmpty{
                self.VAPI.getVideos()
            }
        }
    }

    var body: some View {
        Container(heading: "Video Highlights", width: self.width,ignoreSides: true) { w in
            let size:CGSize = .init(width: w, height: totalHeight * 0.4)
            if self.VAPI.videos.isEmpty{
                ProgressView()
            }else{
                SlideZoomInOutView(data: self.VAPI.videos,timeLimit: 30, size: size, scrollable: true) { data,size in
                    if let videoData = data as? CrybseVideoData{
                        VideoCard(data: videoData, size: size,smallCard: true)
                    }else{
                        ProgressView()
                    }
                    
                }
            }
        }
        .onAppear(perform: self.onAppear)
    }
}

struct CrybseYoutubeHighlightView_Previews: PreviewProvider {
    static var previews: some View {
        CrybseYoutubeHighlightView(width: totalWidth)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            .background(Color.mainBGColor)
            .ignoresSafeArea()
    }
}
