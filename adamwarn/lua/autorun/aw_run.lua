if(SERVER) then
	include("aw/sv_init.lua")
	include("aw/sv_config.lua")
	include("aw/sv_player.lua")
	include("aw/sv_sql.lua")
	include("aw/sh_config.lua")
else
	include("aw/cl_init.lua")
	include("aw/sh_config.lua")
end