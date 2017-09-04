//
//  Vote.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-04.
//

import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension PollHandlers {

	static func vote(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let obj = Poll()
			let vote = PollResponse()
			vote.pollid = request.param(name: "id", defaultValue: "") ?? ""

			if !vote.pollid.isEmpty {
				try? obj.get(vote.pollid)

				if obj.id.isEmpty {
					response.redirect(path: "/")
				}
			}

			vote.userid = contextAccountID
			vote.response = request.param(name: "option", defaultValue: "") ?? ""
			if !vote.vote() {
				// no vote
				response.redirect(path: "/")
			}
			// voted.
			// normally we would do some more stuff here...
			// instead, the home page will just show the poll results
			response.redirect(path: "/")

		}
	}
}

