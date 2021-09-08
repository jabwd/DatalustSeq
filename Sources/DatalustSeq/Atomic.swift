//
//  Atomic.swift
//  
//
//  Created by Antwan van Houdt on 06/08/2021.
//

import Foundation

@propertyWrapper
public class Atomic<T> {
  private var value: T
  public var wrappedValue: T {
    get {
      Seq.queue.sync {
        value
      }
    }
    set {
      Seq.queue.async(flags: .barrier) {
        self.value = newValue
      }
    }
  }

  public init(wrappedValue: T) {
    value = wrappedValue
  }
}
