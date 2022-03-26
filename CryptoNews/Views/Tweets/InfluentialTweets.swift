////
////  InfluentialTweets.swift
////  CryptoNews
////
////  Created by Krishna Venkatramani on 25/08/2021.
////
//
//import SwiftUI
//
//struct InfluentialTweets: View {
//    @StateObject var tweetFeed:FeedAPI = .init(currency: ["BTC","XRP","ETH","LTC"], type: .Influential,limit:50,page:1)
//    
//    func onAppear(){
//        if self.tweetFeed.FeedData.isEmpty{
//            self.tweetFeed.getAssetInfo()
//        }
//    }
//    
//    var body: some View {
////        GeometryReader{g in
//            let w = totalWidth - 30
//            VStack(alignment: .leading, spacing: 10){
//                ForEach(self.tweetFeed.FeedData) { data in
//                    PostCard(cardType: .Tweet, data: data, size: .init(width: w, height: totalHeight * 0.35),const_size: true)
//                }
//            }
////        }
//        
//        .padding(15)
//        .onAppear(perform: self.onAppear)
//        .frame(width: totalWidth, alignment: .center)
////        .frame(minHeight:100,maxHeight:.infinity)
//    }
//}
//
//struct InfluentialTweets_Previews: PreviewProvider {
//    static var previews: some View {
//        InfluentialTweets()
//    }
//}
