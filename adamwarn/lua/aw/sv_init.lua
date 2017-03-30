// INIT FILE \\

include("sv_config.lua")
include("sv_player.lua")
include("sv_sql.lua")
include("sh_config.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_config.lua")

util.AddNetworkString("aw.notify")
util.AddNetworkString("aw.notify_chat")
util.AddNetworkString("aw.echoevent")
util.AddNetworkString("aw.noyify_cmd")
util.AddNetworkString("aw_reqinfo")
util.AddNetworkString("aw_sendinfo")
util.AddNetworkString("aw_sendinfo_staff")
util.AddNetworkString("aw_reqinfo_staff")
util.AddNetworkString("aw_admin_remove_warn")

function aw_PlayerInitialSpawn(ply)
	ply:SetNWBool("Already_Joined", false)
	ply:aw_LoadWarns()
end
hook.Add("PlayerInitialSpawn", "GetWarnings", aw_PlayerInitialSpawn)

function aw_PlayerLeft(ply)
	if(aw_warnings[ply:SteamID()] != nil) then
		table.remove(aw_warnings[ply:SteamID()])
	end
end
hook.Add("PlayerDisconnected", "RemovedTable", aw_PlayerLeft)

function aw_findplayer(str)
	print(str)
	local aw_players = {}
	for k, v in pairs(player.GetAll()) do
		if(string.match(string.lower(str), string.lower(v:Nick()))) then
			table.insert(aw_players, v)
			return aw_players[1]
		else
			return "No players found."
		end
	end
end

function aw_echoevent(text)
	for k, v in pairs(player.GetAll()) do
		net.Start("aw.echoevent")
			net.WriteString(text)
		net.Send(v)
	end
end

net.Receive("aw_reqinfo", function()
	local sid = net.ReadString()
	print(sid)
	local ply = sid
	for k, v in pairs(player.GetAll()) do
		if(v:SteamID()== sid) then
			sid = v
			ply = v
		else
			return
		end
	end
	local q1 = "SELECT id, reason, admin FROM `warns` WHERE steamid = '"..mysqle(ply:SteamID()).."'"
	aw_sql.sql:Query(q1, function(result)
		if(#result > 0 ) then
			timer.Simple(1, function()
			net.Start("aw_sendinfo")
				--for _, data in pairs(result) do
					net.WriteTable(result)
				--end
			net.Send(ply)
			end)
		end
	end)
end)

net.Receive("aw_reqinfo_staff", function()
	local sid = net.ReadString()
	print(sid)
	local ply = sid
	for k, v in pairs(player.GetAll()) do
		if(v:SteamID()== sid) then
			sid = v
			ply = v
		else
			return
		end
	end
	local q1 = "SELECT id, reason, admin FROM `warns` WHERE steamid = '"..mysqle(ply:SteamID()).."'"
	aw_sql.sql:Query(q1, function(result)
		if(#result > 0 ) then
			timer.Simple(1, function()
			net.Start("aw_sendinfo_staff")
				--for _, data in pairs(result) do
					net.WriteTable(result)
				--end
			net.Send(ply)
			end)
		end
	end)
end)

net.Receive("aw_admin_remove_warn", function()
	local adminid = net.ReadString()
	local playerid = net.ReadString()
	local id = net.ReadFloat()
	for k, v in pairs(player.GetAll()) do
		if(v:SteamID()== adminid) then
			adminid = v
		end

		if(v:SteamID()== playerid) then
			playerid = v
		else
			return
		end
	end
	adminid:ConCommand('say "!unwarn '..playerid:Nick()..' '..tostring(id)..'"')
end)

local aw_cmds = {}

function aw_addcmd(cmd, func, access, args)
	aw_cmds[cmd] = {}
	aw_cmds[cmd].func = func
	aw_cmds[cmd].rank = access
	if(args) then
		aw_cmds[cmd].args = args
	end
end


function aw_HandleCommands(ply, text)
	if(string.Left(text, 1)== aw_sh.ChatPrefix) then
		local extend = string.Explode(" ", text)
		local cmd = string.lower(string.Trim(string.sub(extend[1], 2)))
		table.remove(extend, 1)
		local args = extend
		if(aw_cmds[cmd]) then
			if(aw_cmds[cmd].args and (#args < aw_cmds[cmd].args)) then
				ply:aw_notify("You must have "..tostring(#args).." arguments!")
				return
			end
			if(ply:aw_rank(aw_cmds[cmd].rank)) then
				local check, err = pcall(aw_cmds[cmd].func, ply, unpack(args))
				if(!check) then 
					print("Error: \n")
					print("-----------------------------------------------------------------------\n")
					MsgC(Color(255, 0, 0, 255), err.."\n")
					print("\n-----------------------------------------------------------------------\n")
				end
			else
				ply:aw_notify("You do not have access to this command, "..ply:Nick().."!")
			end
		end
	end
end
hook.Add("PlayerSay", "Command_Handle", aw_HandleCommands)

aw_addcmd("test", function(ply, text)
	ply:aw_notify("WORKS!", 2)
	ply:aw_notify_chat("WORKS!")
end, "m", 0)

aw_addcmd("warn", function(ply, victim, reason, ...)
	if(not victim) then
		ply:aw_notify("Error, you must enter a player to warn!", 5)
		return
	end
	if(string.find(victim, "STEAM_")) then
		local endoftext = string.Implode(" ", {...})
		reason = reason.." "..endoftext
		if(aw_sv.MySQL == true) then
			local q1 = "INSERT INTO `warns` (`name`, `steamid`, `reason`, `admin`) VALUES ('Nil', '"..mysqle(victim).."', '"..mysqle(reason).."', '"..mysqle(ply:Name()).."')"
			aw_sql.sql:Query(q1)
		else
			local q = "INSERT INTO warns (name, steamid, reason, admin) VALUES ('Nil', "..sql.SQLStr(victim)..", "..sql.SQLStr(reason)..", "..sql.SQLStr(ply:Name())..");"
			sql.Query(q)
		end
		local text = Format("%s warned SteamID %s for reason %s", ply:Nick(), victim, reason)
		aw_echoevent(text)
		return
	end

	local target = aw_findplayer(victim)
	if(type(target)== "string") then
		ply:aw_notify(target, 5)
		return
	end
	local endoftext = string.Implode(" ", {...})
	reason = reason.." "..endoftext
	target:aw_warn(reason, ply:Name())
	local text = Format("%s warned %s for reason %s", ply:Name(), target:Name(), reason)
	aw_echoevent(text)
end, "m", 2)

aw_addcmd("warnings", function(ply, victim)
	if(string.find(victim, "STEAM_")) then
		if(aw_sv.MySQL == true) then
			local q1 = "SELECT id, reason, admin FROM `warns` WHERE steamid = '"..mysqle(victim).."'"
			aw_sql.sql:Query(q1, function(result)
				if(#result > 0) then
					for k, v in pairs(result) do
						ply:aw_notify_cmd("ID: "..v.id.." | Reason: '"..v.reason.."' | Admin: "..v.admin.."'")
					end
					ply:aw_notify_chat("Warnings printed in console.")
				else
					ply:aw_notify_chat("No warnings found for SteamID '"..victim.."'")
				end
			end)
		else
			local q = sql.Query("SELECT id, reason, admin FROM warns WHERE steamid = "..sql.SQLStr(victim))
			if(#q > 0) then
				for k, v in pairs(q) do
					ply:aw_notify_cmd("ID: "..v.id.." | Reason: '"..v.reason.."' | Admin: "..v.admin.."'")
				end
				ply:aw_notify_chat("Warnings printed in the console.")
				ply:aw_notify_chat(victim.." has "..#result.." warnings.")
			else
				ply:aw_notify_chat("No warnings found for SteamID '"..victim.."'")
			end
		end
		return
	end

	local target = aw_findplayer(victim)
	if(type(target)== "string") then
		ply:aw_notify(target, 5)
		return
	end
	if(aw_sv.MySQL == true) then
		local q1 = "SELECT id, reason, admin FROM `warns` WHERE steamid = '"..target:SteamID().."'"
		aw_sql.sql:Query(q1, function(result)
			if(#result > 0) then
				for k, v in pairs(result) do
					ply:aw_notify_cmd(v.id.." | '"..v.reason.."' | Warend by: '"..v.admin.."'")
				end
				ply:aw_notify_chat("Warnings printed in console.")
				ply:aw_notify_chat(target:Nick().." has "..#result.." warnings.")
			else
				ply:aw_notify_chat(target:Nick().." has no warnings!")
			end
		end)
	else
		local q = "SELECT id, reason, admin FROM warns WHERE steamid = '"..target:SteamID().."'"
		local result = sql.Query(q)
		if(#result > 0) then
			for k, v in pairs(result) do
				ply:aw_notify_cmd(v.id.." | '"..v.reason.."' | Warend by: '"..v.admin.."'")
			end
			ply:aw_notify_chat("Warnings printed in console.")
			ply:aw_notify_chat(target:Nick().." has "..#result.." warnings.")
		else
			ply:aw_notify_chat(target:Nick().." has no warnings!")
		end
	end
end, "m", 1)


aw_addcmd("unwarn", function(ply, victim, warn)
	if(not warn) then
		ply:aw_notify_chat("You must enter the ID of the warning to remove it! To get the warnings, do !warnings <player/steamid>")
		return
	end

	if(type(warn) == "string") then
		//ply:aw_notify("The warning number cannot be a string. SQL Database security enabled. Your IP ("..ply:IPAddress()..") has been logged.")
		warn = tonumber(warn)
	end
	local target = aw_findplayer(victim)
	local id = target:SteamID()
	if(aw_sv.MySQL == true) then
		local q1 = "DELETE FROM `warns` WHERE `id` = "..mysqle(warn).." AND steamid = '"..id.."';"
		aw_sql.sql:Query(q1, function(result)
			ply:aw_notify("Warning deleted...", 3);
		end)
	else
		local q = sql.Query("DELETE FROM warns WHERE id = "..sql.SQLStr(warn).." AND steamid = '"..id.."';")
	end
	target:SetNWBool("Already_Joined", true)
	target:aw_LoadWarns()
end, "m", 2)

aw_addcmd("amenu", function(ply)
	ply:ConCommand("aw_open_menu")
end, "a", 0)