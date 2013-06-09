mongo = require('../mongo.coffee')
randomentropystring = require('../randomstring.coffee').string

module.exports = {
	create: (info, callback) ->
		if info.email != undefined
			mongo.dbhandler (db) ->
				collection = db.collection("invitecodes")
				randomentropystring (str) ->
					random_invite_code = str.string.substr(0, 10)
					stuff_to_insert = {invitecode: random_invite_code, email: info.email}
					if info.metadata != undefined
						stuff_to_insert.metadata = info.metadata
					collection.save stuff_to_insert, (cberr, cbres) ->
						if not cberr
							callback({meta: {code: 200, msg: 'Success'}, data:cbres})
						else
							callback({meta: {code: 500, msg: 'Database error'}, data: {}})
		else
			callback({meta: {code: 400, msg: 'Not enough parameters'}})
}