const Discord = require('discord.js')
const client = new Discord.Client()
import * as env from './env'
import {db} from './database'

# Added with link: https://discord.com/oauth2/authorize?client_id=795710199968039005&scope=bot&permissions=268438614

client.on 'ready' do
	let user = await db.get('users', 'user-2')
	console.log("Logged and db is working:",user)
	console.log("Logged in as {client.user.tag}!")

client.on 'message' do |msg|
	if msg.content === 'ping'
		msg.reply('Pong!')

# console.log "tok", env.get('DISCORD_BOT_TOKEN')
client.login(env.get('DISCORD_BOT_TOKEN'))

