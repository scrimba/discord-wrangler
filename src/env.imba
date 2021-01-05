
const custom = require('../config/env.json')
const fallback = require('../config/env.example.json')
const path = require('path')
const root = __dirname + '/..'
const cached = {}

export def get key
	var value = cached[key]

	if !custom[key] and fallback[key]
		console.warn "ENV variable {key} is only found in env.example.json"

	value ||= process.env[key] or custom[key] or fallback[key]

	if value == undefined and key != key.toUpperCase!
		value = get(key.toUpperCase!)

	if /^\.\//.test(value)
		value = path.resolve(root, value)

	cached[key] ||= value

export def set key, value
	cached[key] = value
	null

export def absPath ...pathname
	return path.resolve(root,...pathname)

export default new Proxy({},{
	get: do(target, name)
		if name == 'path'
			return do(...params) absPath(...params)
		get(name)
	set: do(target, name, value) set(name,value)
})