//
//  PollModAction.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-03.
//

import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension PollHandlers {

	static func modAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			// Verify Admin
			Account.adminBounce(request, response)

			let obj = Poll()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? obj.get(id)

				if obj.id.isEmpty {
					Handlers.redirectRequest(request, response, msg: "Invalid Poll", template: request.documentRoot + "/views/polls.mustache")
				}
			} else if let id = request.param(name: "id"), !id.isEmpty {
				try? obj.get(id)
			}



			if let name = request.param(name: "name"), !name.isEmpty {
				obj.name = name

				var list = [[String:Any]]()
				for option in request.params(named: "option") {
					if !option.isEmpty {
						list.append(["name":option])
					}
				}
				obj.options["items"] = list

				obj.active = Int(request.param(name: "active") ?? "0") ?? 0

				if obj.id.isEmpty {
					obj.makeid()
					try? obj.create()
				} else {
					try? obj.save()
				}

			} else {
				msg = "Please enter the Poll name."
				Handlers.redirectRequest(request, response, msg: msg, template: request.documentRoot + "/views/polls.mustache", additional: [
					"mod?":"true",
					])
			}


			PollHandlers.modDisplay(request, response, obj.id)

		}
	}

}
