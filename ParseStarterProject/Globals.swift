//
//  Globals.swift
//  Pictagram
//
//  Created by Mark Torres on 4/26/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

let userStorage = NSUserDefaults.standardUserDefaults()

var activeUsername = ""
var activePassword = ""

func saveActiveUser() {
	userStorage.setObject(activeUsername, forKey: "activeUsername")
	userStorage.setObject(activePassword, forKey: "activePassword")
}

func loadActiveUser() {
	activeUsername = userStorage.objectForKey("activeUsername") as? String ?? ""
	activePassword = userStorage.objectForKey("activePassword") as? String ?? ""
}

func clearActiveUser() {
	userStorage.removeObjectForKey("activeUsername")
	userStorage.removeObjectForKey("activePassword")
}