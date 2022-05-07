//
//  EventsHighlights.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 04/05/2022.
//

import SwiftUI

struct EventsHighlights: View {
    var events:CrybseEvents
    var width:CGFloat
    
    var allMentionCoins:[String]{
        var allTickers:Set<String> = []
        for tickers in self.events.compactMap({$0.tickers}){
            for ticker in tickers{
                allTickers.insert(ticker)
            }
        }
        return Array(allTickers)
    }
    
    @ViewBuilder func headerView(w:CGFloat) -> some View{
        Container(heading:"Coins Mentioned",headingDivider: false,headingSize: 20,width:w,ignoreSides: false,horizontalPadding: 0,verticalPadding: 0){inner_w in
            CustomWrappedTextHStack(data: self.allMentionCoins, width: w, fontSize: 13.5, fontColor: .white, fontWeight: .medium, padding: 10, borderColor: .gray, clipping: .roundClipping, background: .clear, widthPadding: 10)
        }
    }
    
    func cardSize(w:CGFloat) -> CGSize{
        return .init(width: w * 0.65, height: totalHeight * 0.3)
    }
    
    @ViewBuilder func eventsView(w:CGFloat) -> some View{
        ZoomInScrollView(data: self.events.limitData(limit: 5),centralizeStart: false,size: self.cardSize(w: w),selectedCardSize: self.cardSize(w: w)) { eventData, size, _ in
            if let safeEvent = eventData as? CrybseEventData{
                EventSnapshot(event: safeEvent, width: size.width, height: size.height)
                    .basicCard(size: size)
                    .borderCard(color: .gray, clipping: .roundClipping)
                    .slideZoomInOut(cardSize: size)
                    .padding(.vertical)
            }
        }
    }
    
    var body: some View {
        Container(heading: "Important Events Today", headingColor: .white, headingDivider: false, headingSize: 30, width: self.width) { inner_w in
            self.headerView(w: inner_w)
            self.eventsView(w: inner_w)
        }
        .basicCard()
        .borderCard(color: .gray.opacity(0.45))
    
    }
}

struct EventViewsTester:View{
    var width:CGFloat
    
    init(width:CGFloat = totalWidth - 40){
        self.width = width
    }
    
    func eventsDataLoader() -> CrybseEvents?{
        guard let safeData = readJsonFile(forName: "btcCoinData"), let safeCoinData = CrybseCoinSocialData.parseCoinDataFromData(data: safeData), let events = safeCoinData.events else{return nil}
        return events
        
    }
    
    var body: some View {
        if let safeEvents = self.eventsDataLoader(){
            EventsHighlights(events: safeEvents,width: self.width)
                .background(Color.AppBGColor)
                .ignoresSafeArea()
        }else{
            ProgressView()
        }
        
    }
}

struct EventsHighlights_Previews: PreviewProvider {
    
    static var previews: some View {
        EventViewsTester()
        
    }
}
