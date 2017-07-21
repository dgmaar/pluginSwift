//
//  PushNotification.swift
//  SocketTest
//
//  Created by Alex on 7/13/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation


public class PushNotification {
	
	let key: String;
	let data: String;
	let mode: Mode;
	let tokens: String;
	let pushMode: PushMode;
	
	public static func getPushNotifications(data: String) -> [PushNotification]{
		var list = [PushNotification]()
		
		let split = data.characters.split(separator: ";").map(String.init)
		
		if(!split.isEmpty){
			for p in split {
				let r = newPushNotification(data: p)
				if(r != nil){
					list.append(r!)
				}
			}
		}
		
		return list
	}
	
	private static func newPushNotification(data: String) -> PushNotification! {
		
		if(!data.isEmpty){
			let d = data.characters.split(separator: "&").map(String.init)
			
			if(!d.isEmpty){
				let mode:String = d[0];
				let key:String = d[1];
				let dr:String = d[2];
				let push:String = d[3];
				let tokens:String = d[4];
				
				return PushNotification(key: key, data: dr, mode: PushNotification.getMode(e:mode), tokens: tokens, pushMode: PushNotification.getPushMode(e:push));
			}
		}
		
		return nil;
	}
	
	public init(key: String, data:String){
		self.key = key;
		self.data = data;
		self.mode = Mode.REPLY;
		self.tokens = "NULL";
		self.pushMode = PushMode.ALL;
	}
	
	public init(key: String, data:String, mode:Mode){
		self.key = key;
		self.data = data;
		self.mode = mode;
		self.tokens = "NULL";
		self.pushMode = PushMode.ALL;
	}
	
	public init(key: String, data: String, mode: Mode, tokens:String, pushMode:PushMode) {
		self.key = key;
		self.data = data;
		self.mode = mode;
		self.tokens = tokens;
		self.pushMode = pushMode;
	}
	
	public func getKey() -> String{
		return self.key;
	}
	
	public func getData() -> String{
		return self.data;
	}
	
	public func getMode() -> Mode{
		return self.mode;
	}
	
	public func getTokens() -> String{
		return self.tokens;
	}
	
	public func getPushMode() -> PushMode{
		return self.pushMode;
	}
	
	public func getNotification() -> String {
		return toStringMode(m: self.mode) + "&" + self.key + "&" + self.data + "&" + toStringPushMode(m: self.pushMode) + "&" + self.tokens + ";"
	}
	
	func toStringPushMode(m:PushMode) -> String{
		switch m {
		case PushMode.ALL:
			return "A";
		case PushMode.FILTERING:
			return "F";
		case PushMode.IGNORING:
			return "I";
		}
	}
	
	public func toStringMode(m:Mode) -> String{
		switch(m){
		case Mode.NONREPLY:
			return "noreply";
		case Mode.REPLY:
			return "reply";
		}
	}
	
	public static func getMode(e:String) -> Mode{
		switch(e){
		case "noreply":
			return Mode.NONREPLY;
		case "reply":
			return Mode.REPLY;
		default:
			return Mode.REPLY;
		}
	}
	
	public static func getPushMode(e:String) -> PushMode{
		switch(e){
		case "A":
			return PushMode.ALL;
		case "F":
			return PushMode.FILTERING;
		case "I":
			return PushMode.IGNORING;
		default:
			return PushMode.ALL;
		}
	}
	
	public enum PushMode{
		case IGNORING
		case FILTERING
		case ALL;
	}
	
	public enum Mode{
		case REPLY
		case NONREPLY;
	}
	
	
}
