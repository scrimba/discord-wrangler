const Discord = require('discord.js')
const client = new Discord.Client()
import * as env from './env'
import {db} from './database'
const GUILD_ID = '684009642984341525'
const PRO_ROLE = '726419892286390282'

# Bot added with link: https://discord.com/oauth2/authorize?client_id=xxx&scope=bot&permissions=268438614

client.on 'ready' do
	console.log("Logged in as {client.user.tag}!")

client.on 'message' do |msg|
	unless msg.channel.type == 'dm'
		return

	switch msg.content
		when 'ping'
			msg.reply('Pong!')
		when 'help'
			msg.reply("You have to most of the work, but here are some things I can help you with:")
			msg.reply(" `help` - You are looking at it!")
			msg.reply(" `pro` - I´ll flag you as a pro user if you have an active scrimba subscription")
		when 'pro'
			console.log "Pro request from user {msg.author.id} - {msg.author.username}"
			let user = await db.table('users').where('discord_id', msg.author.id).first!
			unless user
				return msg.reply('You need to connect your discord and scrimba users. Shortcut if you are logged into scrimba: https://scrimba.com/discord/connect')

			let sub =  await db.table('subscriptions').where('uid', user.id).where('active', true).first!
			unless sub
				return msg.reply('You are not pro!')

			let guild = client.guilds.cache.get(GUILD_ID)
			let m = await guild.members.fetch(msg.author)
			m.roles.add(PRO_ROLE)
			console.log "Added pro badge to user {user.id}"
			msg.reply('Alright, I found your subscription and added your pro badge. Happy coding!')

client.login(env.get('DISCORD_BOT_TOKEN'))
