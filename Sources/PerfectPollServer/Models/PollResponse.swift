//
//  PollResponse.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-03.
//

import PerfectLib
import StORM
import PostgresStORM
import PerfectCrypto
import SwiftRandom

public class PollResponse: PostgresStORM {
	public var id			= ""
	public var pollid		= ""
	public var userid		= ""
	public var response		= ""

	var _rand = URandom()

	public override init(){
		super.init()
	}

	public static func runSetup() {
		do {
			let this = PollResponse()
			try this.setup()
		} catch {
			print(error)
		}
	}

	// adding function to prevent new vote for a poll if user has already voted!
	public func vote() -> Bool {
		if voted(userid) {
			return false
		}
		if response.isEmpty {
			return false
		}
		id = _rand.secureToken
		do {
			try create()
		} catch {
			print(error)
			return false
		}
		return true
	}

	// has user voted
	public func voted(_ user: String) -> Bool {
		try? find(["userid": user])
		if !id.isEmpty {
			return true
		}
		return false
	}

	override public func to(_ this: StORMRow) {
		id 			= StORMPatch.Extract.string(this.data, "id", "")!
		pollid 		= StORMPatch.Extract.string(this.data, "pollid", "")!
		userid		= StORMPatch.Extract.string(this.data, "userid", "")!
		response 	= StORMPatch.Extract.string(this.data, "response", "")!
	}

	public func rows() -> [PollResponse] {
		var rows = [PollResponse]()
		for i in 0..<self.results.rows.count {
			let row = PollResponse()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}


