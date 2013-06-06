apicommon
=========

General Utilities thats needed to roll your own API with invite codes, api key generation, etc.

Use of this code is at your own risk. It may help you it may not

How I use it
---------

In another library file

```coffeescript
generateinvitecode = require('./apicommon/generateinvitecode.coffee').create

generateapikey = require('./apicommon/generateapikey.coffee').create
```
