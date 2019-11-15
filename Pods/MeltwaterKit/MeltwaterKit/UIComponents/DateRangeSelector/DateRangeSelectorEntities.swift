//
// Created by Gavin Ryan on 8/22/18.
// Copyright (c) 2018 Meltwater. All rights reserved.
//

import Foundation

public enum DateRangeOptionsEnumeration: Int {

    case today
    case thisWeek
    case last7Days
    case thisMonth
    case last30Days
    case thisQuarter
    case custom

}

@objc public class DateRangeSelectionSessionData : NSObject{
    public var dateRangeType:DateRangeOptionsEnumeration = .last7Days
    public var customStartDate:Date?
    public var customEndDate:Date?
    override public init(){
        dateRangeType = .last7Days
    }
    public init(dateRange:DateRangeOptionsEnumeration) {
        dateRangeType = dateRange
    }
}

public class DateRangeOptions {
    public var optionsArray: [DateRangeOptionsEnumeration]

    public init() {
        optionsArray = [DateRangeOptionsEnumeration]()
    }

    public init(default: Bool) {
        optionsArray = [.today, .thisWeek, .last7Days, .thisMonth, .last30Days, .thisQuarter, .custom]
    }

    public init(dateOptions: [DateRangeOptionsEnumeration]) {
        optionsArray = dateOptions
    }

    public func getRangeDataForUI(atIndex: Int) -> (title: String, days: String, rangeValue: DateRangeOptionsEnumeration)? {
        guard (..<optionsArray.count).contains(atIndex) else {
            return nil
        }
        let value = optionsArray[atIndex]
        switch value {
        case .today:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_TODAY", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)
        case .thisWeek:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_THIS_WEEK", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)

        case .last7Days:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_LAST_7_DAYS", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)

        case .thisMonth:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_THIS_MONTH", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)

        case .last30Days:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_LAST_30_DAYS", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)

        case .thisQuarter:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_THIS_QUARTER", comment: ""), days: makeStartDateString(interval: value), rangeValue: value)
        case .custom:
            return (title: MWKitLocalize.shared.LocalizeWithDefault("DATE_OPTION_CUSTOM", comment: ""), MWKitLocalize.shared.LocalizeWithDefault("SELECT_PROMPT", comment: ""), rangeValue: value)
        }
    }
}

    public func makeStartDateString(interval:DateRangeOptionsEnumeration) -> String{
        //"2017-12-30T00:00:00"
        let endDate:Date =  Date.init()
        var dateComponent = DateComponents()
        var startDate:Date?
        switch interval {
        case .last7Days:
            startDate = Calendar.current.startOfDay(for: endDate)
            dateComponent.day = -6
            startDate = Calendar.current.date(byAdding: dateComponent, to: startDate!)
            break
        case .today:
            startDate = Calendar.current.startOfDay(for: endDate)
            break
        case .thisWeek:
            //by default the dateComponents for time will be zero
            startDate = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: endDate))
            break
        case .thisMonth:
            //by default the dateCOmponents for time will be zero
            var component = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            component.day = 1
            startDate = Calendar.current.date(from: component)
            break
        case .thisQuarter:
            //by default the dateCOmponents for time will be zero
            var component = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            let curMonth:Int =  component.month ?? 1
            switch curMonth {
            case 1,2,3:
                component.month = 1
            case 4,5,6:
                component.month = 4
            case 7,8,9:
                component.month = 7
            case 10,11,12:
                component.month = 10
            default:
                component.month = 1
                break
            }
            component.day = 1
            startDate = Calendar.current.date(from: component)
            break
        case .last30Days:
            startDate = Calendar.current.startOfDay(for: endDate)
            dateComponent.day = -29
            startDate = Calendar.current.date(byAdding: dateComponent, to: endDate)
            break
        case .custom:
            //do nothing. The label is "Select"
            break
        }
        let stringForSingleDayFormat = "MMM d"
        var firstDayString: String?
        if let start = startDate {
            firstDayString = MWDateFormatter.shared.stringLocaleFormatted(date: start, dateComponents: stringForSingleDayFormat)
        }        
        let lastDayString = MWDateFormatter.shared.stringLocaleFormatted(date: endDate, dateComponents: stringForSingleDayFormat)
//         In case the user selected .today the value of firstDay will be nil, then just use lastDayString
        var daysIntervalString = ""
        if let first = firstDayString {
            daysIntervalString = first + "-" + lastDayString
        } else {
            daysIntervalString = lastDayString
        }
        return daysIntervalString
    }

protocol DateRangeSessionDataProtocol {
    func getSavedDateRange() -> DateRangeSelectionSessionData?
}
