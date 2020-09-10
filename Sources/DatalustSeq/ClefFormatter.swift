//
//  ClefFormatter.swift
//  
//
//  Created by Antwan van Houdt on 10/09/2020.
//

import Foundation
import Logging

internal final class ClefFormatter {
	let dateFormatter: DateFormatter

	init() {
		dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
	}
	
	func format(message: Message) -> String {
		return ""
	}
}

extension Logger.Level {
	var displayString: String {
		switch self {
		case .trace:
			return "trace"
		case .debug:
			return "debug"
		default:
			return "critical"
		}
	}
}
