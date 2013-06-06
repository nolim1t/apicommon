mongo = require('../mongo.coffee')
randomentropystring = require('../randomstring.coffee').string

module.exports = {
	create: (info, callback) ->
		if info.identifier != undefined
			mongo.dbhandler (db) ->
				collection = db.collection("apikeys")
				collection.ensureIndex({expiry: 1}, {expireAfterSeconds: 60})
				randomentropystring (cb) -> 
					key = cb.string
					# defaultexpiry
					expiryts = Math.round(new Date().getTime() / 1000) + 604800
					to_insert = {
						owner: {identifier: info.identifier},
						apikey: key,
						limit: 60,
						expiry: new Date(expiryts * 1000)
					}
					collection.save to_insert, (akerr, akcreated) ->
						if not akerr
							callback({meta: {code: 200, msg: 'OK'}, data: akcreated})
						else
							callback({meta: {code: 500, msg: 'DB Internal error'}})
		else
			callback({meta: {code: 400, msg: 'Invalid parameters'}})
}