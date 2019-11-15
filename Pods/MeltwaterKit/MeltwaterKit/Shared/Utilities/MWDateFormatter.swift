//
//  MWDateFormatter.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 2/22/18.
//  Copyright © 2018 Meltwater. All rights reserved.
//

import Foundation

public class MWDateFormatter {
    let shortDateFormatter = DateFormatter()
    let rfcDateFormatterUTC = DateFormatter()
    let rfcDateFormatter = DateFormatter()
    
    static var shared:MWDateFormatter = MWDateFormatter()
    
    init() {
        shortDateFormatter.dateStyle = .medium
        shortDateFormatter.timeStyle = .none
        shortDateFormatter.locale = Locale(identifier: "en_US")
        shortDateFormatter.timeZone = TimeZone.current
        
        rfcDateFormatterUTC.locale = Locale(identifier: "en_US_POSIX")
        rfcDateFormatterUTC.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        rfcDateFormatterUTC.timeZone = TimeZone.current
        
        rfcDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfcDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        rfcDateFormatter.timeZone = TimeZone.current
        
    }
    public func RFC3339DateFormatWithZ(date: Date) -> String {
        return rfcDateFormatterUTC.string(from: date)
    }
    
    public func RFC3339DateFormat(date: Date) -> String {
        return rfcDateFormatter.string(from: date)
    }
    
    public func shortDateFormat(date: Date) -> String {
        return shortDateFormatter.string(from: date)
    }
    
    public func shortFormatToDate(shortFormat: String) -> Date? {
        return shortDateFormatter.date(from: shortFormat)
    }
    
    public func rfcFormatToDate(formattedDate: String) -> Date? {
        return rfcDateFormatter.date(from: formattedDate)
    }
    
    public func rfcUTCFormatToDate(formattedDate: String) -> Date? {
        return rfcDateFormatterUTC.date(from: formattedDate)
    }
    
    public func stringLocaleFormatted(date: Date, dateComponents: String) -> String {
        let dateFormatter: DateFormatter = self.getDateFormatter(dateComponents: dateComponents)
        return dateFormatter.string(from: date)
    }
    
    func getDateFormatter(dateComponents: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: dateComponents, options: 0, locale: Locale.current)
        dateFormatter.dateFormat = format
        return dateFormatter
    }
}
