//
//  DateHelper.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 08/02/2022.
//

import Foundation

extension Date{
    
    func stringDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter.string(from: self)
    }
    
    func stringDataTime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY HH:mm"
        return formatter.string(from: self)
    }
    
    static func date_w_TimeString(isoTime:String) -> String{
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withFractionalSeconds]
        return isoDateFormatter.date(from: isoTime)?.stringDataTime() ?? isoTime
    }
}
