//
//  PollDelete.swift
//  PerfectPollServer
//
//  Created by Jonathan Guthrie on 2017-09-03.
//

import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension PollHandlers {

	static func delete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			if (request.session?.userid ?? "").isEmpty { response.completed(status: .notAcceptable) }

			// Verify Admin
			Account.adminBounce(request, response)

			let obj = Poll()

			if let id = request.urlVariables["id"] {
				try? obj.get(id)

				if obj.id.isEmpty {
					Handlers.errorJSON(request, response, msg: "Invalid Poll")
				} else {
					try? obj.delete()
				}
			}


			response.setHeader(.contentType, value: "application/json")
			var resp = [String: Any]()
			resp["error"] = "None"
			do {
				try response.setBody(json: resp)
			} catch {
				print("error setBody: \(error)")
			}
			response.completed()
			return
		}
	}
}

