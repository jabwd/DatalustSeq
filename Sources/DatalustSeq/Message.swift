//
//  Message.swift
//  
//
//  Created by Antwan van Houdt on 10/09/2020.
//

import Logging

struct Message {
	final class MessageBox {
		let level: Logger.Level
		let file: String
		let function: String
		let line: UInt
		let message: String
		let metadata: [String: String]
		
		init(
			level: Logger.Level,
			message: Logger.Message,
			file: String,
			function: String,
			line: UInt,
			metadata: Logger.Metadata
		) {
			self.file = file
			self.function = function
			self.line = line
			self.message = message.description
			self.level = level
			self.metadata = [:]
		}
	}
	
	private let box: MessageBox
	
	init(
		level: Logger.Level,
		message: Logger.Message,
		file: String,
		function: String,
		line: UInt,
		metadata: Logger.Metadata
	) {
		box = MessageBox(
			level: level,
			message: message,
			file: file,
			function: function,
			line: line,
			metadata: metadata
		)
	}
	
	var level: Logger.Level { box.level }
	var file: String { box.file }
	var function: String { box.function }
	var line: UInt { box.line }
	var message: String { box.message }
}
