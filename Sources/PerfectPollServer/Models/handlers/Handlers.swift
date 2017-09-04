//
//  Handlers.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import StORM
import LocalAuthentication

class Handlers {

	// Basic "main" handler - simply outputs "Hello, world!"
	static func main(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let users = Account()
			try? users.findAll()
			if users.rows().count == 0 {
				response.redirect(path: "/initialize")
				response.completed()
				return
			}

			var context: [String : Any] = ["title": configTitle]
			let userid = request.session?.userid ?? ""
			if !userid.isEmpty { context["authenticated"] = true }

			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			if !userid.isEmpty {
				let thisPoll = Poll()
				let thisPollResponse = PollResponse()
				try? thisPoll.findOne(orderBy: "active DESC, name")
				if thisPollResponse.voted(userid) {
					context["poll"] = [
						"name": thisPoll.name,
						"options": thisPoll.options,
						"id": thisPoll.id,
						"voted?": "true",
						"results": thisPoll.results()
					]
				} else {
					// simple poll display
					context["poll"] = [
						"name": thisPoll.name,
						"options": thisPoll.options,
						"id": thisPoll.id
					]
				}
			}
			response.renderMustache(template: request.documentRoot + "/views/index.mustache", context: context)
		}
	}

}
