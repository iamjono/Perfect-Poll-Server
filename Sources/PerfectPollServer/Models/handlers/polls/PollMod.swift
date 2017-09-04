//
//  PollMod.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-03.
//

import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension PollHandlers {

	static func modDisplay(_ request: HTTPRequest, _ response: HTTPResponse, _ newid: String = "") {

		let contextAccountID = request.session?.userid ?? ""
		let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
		if !contextAuthenticated { response.redirect(path: "/login") }

		let obj = Poll()
		var action = "Create"

		let id = request.urlVariables["id"] ?? newid

		if !id.isEmpty {
			try? obj.get(id)

			if obj.id.isEmpty {
				Handlers.redirectRequest(request, response, msg: "Invalid Poll", template: request.documentRoot + "/views/poll.mustache")
			}

			action = "Edit"
		}
		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"mod?":"true",
			"action": action,
			"name": obj.name,
			"options": obj.options,
			"active": obj.active,
			"id": obj.id
		]
		if contextAuthenticated {
			for i in Handlers.extras(request) {
				context[i.0] = i.1
			}
		}
		// add app config vars
		for i in Handlers.appExtras(request) {
			context[i.0] = i.1
		}
		response.renderMustache(template: request.documentRoot + "/views/polls.mustache", context: context)
	}
	static func mod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			// Verify Admin
			Account.adminBounce(request, response)

			modDisplay(request, response)
		}
	}

}
