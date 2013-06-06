mongo = require('../mongo.coffee')
randomentropystring = require('../randomstring.coffee').string

module.exports = {
	create: (info, callback) ->
		if info.email != undefined
			mongo.dbhandler (db) ->
				collection = db.collection("invitecodes")
				randomentropystring (str) ->
					random_invite_code = str.string.substr(0, 10)
					collection.save {invitecode: random_invite_code, email: info.email}, (cberr, cbres) ->
						if not cberr
							callback({meta: {code: 200, msg: 'Success'}, data:cbres})
						else
							callback({meta: {code: 500, msg: 'Database error'}, data: {}})
		else
			callback({meta: {code: 400, msg: 'Not enough parameters'}})
}