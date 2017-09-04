//
//  Poll.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-03.
//

import PerfectLib
import StORM
import PostgresStORM
import PerfectCrypto
import SwiftRandom


public class Poll: PostgresStORM {
	public var id						= ""
	public var name						= ""
	public var active					= 1
	public var options					= [String:Any]()

	var _rand = URandom()

	public override init(){
		super.init()
	}

	public func makeid() {
		id = _rand.secureToken
	}

	public static func runSetup() {
		do {
			let this = Poll()
			try this.setup()
		} catch {
			print(error)
		}
	}

	override public func to(_ this: StORMRow) {
		id 			= StORMPatch.Extract.string(this.data, "id", "")!
		name 		= StORMPatch.Extract.string(this.data, "name", "")!
		active 		= StORMPatch.Extract.int(this.data, "active", 0)!
		options		= StORMPatch.Extract.map(this.data, "options",[String:Any]())!
	}

	public func rows() -> [Poll] {
		var rows = [Poll]()
		for i in 0..<self.results.rows.count {
			let row = Poll()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	// taken from ApplicationExtension and updated to Poll data
	public static func list() -> [[String: Any]] {
		var list = [[String: Any]]()
		let t = Poll()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "true",
			params: [],
			orderby: ["name"],
			cursor: cursor
		)


		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["name"] = row.name
			r["active"] = row.active
			r["options"] = row.options["items"]
			list.append(r)
		}
		return list

	}

	public func results() -> [[String: Any]] {
		var aggregated = [[String: Any]]()
		let o = options["items"] as? [[String:Any]] ?? [[String:Any]]()
		for option in o  {
			let votes = PollResponse()
			try? votes.find(["pollid": id, "response": option["name"] as? String ?? ""])
			aggregated.append(["option": option["name"] as? String ?? "", "votes": votes.results.cursorData.totalRecords])
		}
		return aggregated
	}

}


