//
//  AuthConstants.swift
//  MeltwaterKit
//
//  Created by Thinh Nguyen on 6/6/17.
//  Copyright © 2017 Meltwater. All rights reserved.
//

import Foundation

public class EnrichmentConstants {
    static let titleCoefficientKey = "ttCoef"
    static let bodyCoefficientKey = "bdCoef"
    static let matchSentenceCoefficientKey = "msCoef"
    static let zThresholdKey = "zThreshold"
    static let reachCoefficientKey = "rcCoefficient"
    static let sampleSizeKey = "sampleSize"
    static let alertTypeKey = "alertType"
}

public enum HTTPStatusCodes: Int {
    case Ok = 200
    case BadRequest = 400
    case Unauthorized = 401
    case InternalServerError = 500
}

public class DateConstants {
    static let sevenDaysInSeconds = 3600 * 24 * 7
}

public enum AlertType: String {
    case None = "none"
    case Reach = "reach"
    case Sentiment = "sentiment"
    case Rank = "rank"
}

public enum SentimentType: String {
    case Unknown = "U"
    case Neutral = "N"
    case Positive = "P"
    case Negative = "V"
}

public class QueryConstants {
    static let dateStart = "dateStart"
    static let dateEnd = "dateEnd"
}
