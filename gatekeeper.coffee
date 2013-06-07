mongo = require('../mongo.coffee')

# Handles API Key validation, logging, and rate limiting
module.exports = {
	validate: (info, callback) ->
		if info.apikey != undefined
			mongo.dbhandler (db) ->
				apikeycoll = db.collection("apikeys")
				requesthistorycoll = db.collection("apikeyrequests")
				requesthistorycoll.ensureIndex({expiry: 1}, {expireAfterSeconds: 60})
				now = Math.round(new Date().getTime() / 1000)
				apikeyttl = process.env.APIKEYTTL || 60
				newexpiry = Math.round(new Date().getTime() / 1000) + parseInt(apikeyttl)
				query = {
					apikey: info.apikey
				}
				apikeycoll.find(query).toArray (keyErr, keyArr) ->
					if not keyErr
						if keyArr.length == 1
							requesthistorycoll.find({apikey: info.apikey}).toArray (rlErr, rlArr) ->
								if not rlErr
									if rlArr.length <= keyArr[0].limit
										# Must have less requests. Then log a request asynchronously
										requesthistorycoll.save {apikey: info.apikey, expiry: new Date(now * 1000)}, (historyerr, historycb) -> console.log historycb
										# Refresh API key because its used
										apikeycoll.update query, {$set: {expiry: new Date(newexpiry * 1000)}}, (updateErr, updateSuccess) -> console.log updateSuccess
										# After logging request then  say its ok
										requests_remaining = parseInt(keyArr[0].limit) - rlArr.length
										callback({meta: {code: 200, msg: 'OK'}, data: {requests_remaining: requests_remaining, owner: keyArr[0].owner}})
									else
										# Rate limit exceeded
										callback({meta: {code: 429, msg: 'Rate limit exceeded'}})
								else
									callback({meta: {code: 500, msg: 'database error'}})	
						else
							callback({meta: {code: 401, msg: 'Invalid API Key'}})
					else
						callback({meta: {code: 500, msg: 'database error'}})

		else
			callback({meta: {code: 400, msg: 'Bad parameters'}})
}