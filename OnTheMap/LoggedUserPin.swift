//
//  LoggedUserPin.swift
//  OnTheMap
//
//  Created by Mauricio A Cabreira on 16/09/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import Foundation


class LoggedUserPin {
  var pin: [Pin] = []
  
  static let sharedInstance = LoggedUserPin()
}
