// CLIENTSIDE SQL FILE \\
include("sh_config.lua")

net.Receive("aw.notify", function()
	local str = net.ReadString();
	local len = net.ReadFloat();
	str = "[Server] "..str
	notification.AddLegacy(str, 2, len)
end)

net.Receive("aw.notify_chat", function()
	local str = net.ReadString()

	chat.AddText(Color(0, 100, 200, 255), "[Server] ", Color(255, 255, 255, 255), str)
end)

net.Receive("aw.echoevent", function()
	local str = net.ReadString()
	chat.AddText(Color(0, 100, 200, 255), "[Server] ", Color(255, 255, 255, 255), str)
end)

net.Receive("aw.noyify_cmd", function()
	local str = net.ReadString()
	MsgC(Color(0, 100, 200, 255), "\n----------------------------------\n")
	MsgC(Color(255, 255, 255, 255), str)
	MsgC(Color(0, 100, 200, 255), "\n----------------------------------\n")
end)


function aw_menu()
	local ply = LocalPlayer()

	local frame = vgui.Create("DFrame")
		frame:SetSize(500, 500)
		frame:Center()
		frame:SetTitle("Adam Warns' Menu")
		frame:SetDraggable(false)
		frame:MakePopup()
	local sheet1 = vgui.Create("DPropertySheet", frame)
		sheet1:Dock(FILL)
	local warns_p = vgui.Create("DPanel", sheet1)
		sheet1:AddSheet("Your warnings", warns_p, "icon16/cross.png")
		local warns = vgui.Create("DListView", warns_p)
			warns:SetSize(250, 250)
			warns:AlignTop(5)
			warns:AlignLeft(100)
			warns:AddColumn("ID", 1)
			warns:AddColumn("Reason", 2)
			warns:AddColumn("Admin", 3)
			timer.Simple(0.5, function()
			net.Start("aw_reqinfo")
				net.WriteString(ply:SteamID())
			net.SendToServer()
			end)
			timer.Simple(1.5, function()
			net.Receive("aw_sendinfo", function()
				local data = net.ReadTable()
				for k, v in pairs(data) do
					print(v.id)
					warns:AddLine(v.id, v.reason, v.admin)
				end
			end)
			end)

	if(ply:GetUserGroup()== "moderator" or ply:IsAdmin()) then
		local warns_a = vgui.Create("DPanel", sheet1)
			sheet1:AddSheet("Staff CP", warns_a, "icon16/emoticon_smile.png")

			local swarns = vgui.Create("DListView", warns_a)
				swarns:SetSize(250, 250)
				swarns:AlignTop(5)
				swarns:AlignLeft(105)
				swarns:AddColumn("ID", 1)
				swarns:AddColumn("Reason", 2)
				swarns:AddColumn("Admin", 3)

				swarns.OnRowRightClick = function(row, id)
					local sid = row:GetLine(id):GetValue(4)
					print(sid) -- debug
					net.Start("aw_admin_remove_warn")
						net.WriteString(ply:SteamID())
						net.WriteString(sid)
						net.WriteFloat(row:GetLine(id):GetValue(1))
					net.SendToServer()
					row:GetLine(id):Remove()
					frame:Close();
				end
			local play
			local players = vgui.Create("DListView", warns_a)
				players:SetSize(100, 250)
				players:AlignTop(5)
				players:AddColumn("Player")
				players:SetMultiSelect(false)

				for k, v in pairs(player.GetAll()) do
					players:AddLine(""..v:Name(), ""..v:SteamID())
				end

				players.OnRowSelected = function(row, id)
					play = row:GetLine(id):GetValue(2)
					timer.Simple(1, function()
						net.Start("aw_reqinfo_staff")
							net.WriteString(row:GetLine(id):GetValue(2))
						net.SendToServer()
					end)
				end

				net.Receive("aw_sendinfo_staff", function()
						local data = net.ReadTable()
						for _, d in pairs(data) do
							print(d.id)
							swarns:AddLine(d.id, d.reason, d.admin, play)
						end
				end)
	end
end
concommand.Add("aw_open_menu", aw_menu)