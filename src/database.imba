import * as env from './env'
import * as knex from 'knex'
import * as driver from 'pg'
const pg-pool = require 'pg-pool'
const crypto = require 'crypto'

const pguri = "postgres://{env.get('PG_URI')}"

export const db = knex(
	client: 'pg'
	connection: pguri
	debug: false
	pool: { min: 1, max: 100 }
)

export const pg = new pg-pool(connectionString: pguri)

var timings = {}
var cachedTableVersionMap = {}

# logging queries and their performance
db.on 'query' do(spec)
	let id = spec.__knexQueryUid
	timings[id] = [Date.now!,spec.sql]

db.on 'query-response' do(res,obj,builder)
	let id = obj.__knexQueryUid
	if timings[id]
		let t = Date.now! - timings[id][0]
		let q = timings[id][1]
		if t > 40
			q = q.replace(/\([\?,/ ]+\)/g) do(m)
				let count = m.split("?").length - 1
				return "({count}*?)"
			console.log q,'took',t
		delete timings[id]


const fields =
	users: 'id,username,name,location,bio,twitter_handle,medium_handle,github_handle'
	scrims: 'id,username,name,location,bio,twitter_handle,medium_handle,github_handle'


db.get = do(table, query, o = {})
	if typeof query == 'string'
		query = {id: query}
	return null unless query

	let q = this.table(table).where(query)
	if o.fields
		let fields = (o.fields).split(',')
		q = q.select(...fields)
	let res = await q.first!
	return res

db.getSetting = do(key)
	let out = await db.get('settings',key: key)
	out ? out.value : null
	
db.ins = do(table,data)
	let ins = {}
	for own k,v of data
		if k != k.toLowerCase!
			continue
		if k[0] == '$' or k[0] == '_'
			continue
		ins[k] = v

	# data = self.serializeData(table,data)
	var row = await this.table(table).insert(ins).returning('*')
	return row[0] or row

db.upd = do(table,query,data)
	if typeof query == 'string'
		query = {id: query}

	let upd = {}
	for own k,v of data
		if k != k.toLowerCase!
			continue
		if k[0] == '$' or k[0] == '_'
			continue
		upd[k] = v

	var row = await this.table(table).where(query).update(upd).returning('*')
	return row[0] or row

db.uploadBlob = do(data,meta = {})
	if data isa String
		data = Buffer.from( data, 'utf8' )

	const hash = crypto.createHash('sha1').update(data).digest('hex')
	const id = "sha1:{hash}"
	var exists = await db.table('blobs').where(id: id).first('id')
	await (!exists and db.raw('INSERT INTO blobs (id, content, uid) VALUES (?, ?, ?) ON CONFLICT DO NOTHING', [id, data, meta.uid]))
	return id