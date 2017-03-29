// SERVERSIDE PLAYER METATABLE \\

local meta = FindMetaTable("Player")

function meta:aw_notify(str, num)
	if(not num or num == nil) then num = 5 end
	net.Start("aw.notify")
		net.WriteString(str)
		net.WriteFloat(num)
	net.Send(self)
end

function meta:aw_notify_chat(str)
	net.Start("aw.notify_chat")
		net.WriteString(str)
	net.Send(self)
end

function meta:aw_hasaccess()
	for k, v in pairs(aw_sh.Access) do
		if(self:GetUserGroup()== v) then
			return true
		else
			return false
		end
	end
	return false
end

function meta:aw_notify_cmd(str)
	net.Start("aw.noyify_cmd")
		net.WriteString(str)
	net.Send(self)
end

function meta:aw_rank(str)
	if(str == "m") then 
		str = "moderator" 
	elseif(str == "a") then
		str = "admin"
	elseif(str == "s") then
		str = "superadmin"
	elseif(str == "o") then -- owner
		str = "owner"
	end

	if(str == "moderator" and (self:GetUserGroup()== "moderator" or self:GetUserGroup()== "admin" or self:GetUserGroup()== "superadmin" or self:GetUserGroup()== "owner")) then
		return true
	elseif(str == "admin" and (self:GetUserGroup()== "admin" or self:GetUserGroup()== "superadmin" or self:GetUserGroup()== "owner")) then
		return true
	elseif(str == "superadmin" and (self:GetUserGroup()== "superadmin" or self:GetUserGroup()== "owner")) then
		return true
	elseif(str == "owner" and (self:GetUserGroup()== "owner")) then
		return true
	else
		return false
	end
	return false
end

function meta:aw_warn(reason, admin)
	if(aw_sv.MySQL) then
		local q1 = "INSERT INTO `warns` (`name`, `steamid`, `time_warned`, `reason`, `admin`) VALUES '"..mysqle(self:Name()).."', '"..self:SteamID().."', CURRENT_TIMESTAMP, '"..mysqle(reason).."', '"..mysqle(admin).."';"
		aw_sql.sql:Query(q1)
		self:aw_LoadWarns()
	else
		sql.Query("INSERT INTO warns (name, steamid, reason, admin) VALUES ("..sql.SQLStr(self:Name())..", '"..self:SteamID().."', "..sql.SQLStr(reason)..", "..sql.SQLStr(admin)..");")
		print(sql.LastError())
	end
end

function meta:aw_LoadWarns()
	local id = self:SteamID();
	aw_warnings[self:SteamID()] = {};
	if(aw_sv.MySQL == true) then
		local q1 = "SELECT * FROM `warns` WHERE steamid = '"..id.."';"
		aw_sql.sql:Query(q1, function(result)
			if(#result <= 0 or result == nil) then
				return
			else
				for k, v in pairs(result) do
					table.insert(aw_warnings[self:SteamID()], v)
					PrintTable(aw_warnings)
				end

				for _, a in pairs(player.GetAll()) do
					if(a:aw_hasaccess() and self:GetNWBool("Already_Joined") != true) then
						a:aw_notify_chat(self:Nick().." joins the game with "..#result.." warns!")
					else
						return
					end
				end
			end
		end)
	else
		local query = "SELECT * FROM `warns` WHERE steamid = '"..id.."'"
		local result = sql.Query(query)
		for k, v in pairs(result) do
			table.insert(aw_warnings[self:SteamID()], v)
			PrintTable(aw_warnings[self:SteamID()])
		end

		for _, a in pairs(player.GetAll()) do
			if(a:aw_hasaccess() and self:GetNWBool("Already_Joined") != true) then
				a:aw_notify_chat(self:Nick().." joins the game with "..#result.." warns!")
			end
		end
	end
end