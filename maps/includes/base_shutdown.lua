
-- base_shutdown.lua

-----------------------------------------------------------------------------
-- includes
-----------------------------------------------------------------------------
IncludeScript("base");
IncludeScript("base_ctf");
IncludeScript("base_teamplay");
IncludeScript("base_location");
IncludeScript("base_respawnturret");

-----------------------------------------------------------------------------
-- global overrides
-----------------------------------------------------------------------------
POINTS_PER_CAPTURE = 10;
FLAG_RETURN_TIME = 60;

-----------------------------------------------------------------------------
-- Buttons
-----------------------------------------------------------------------------

-- base button stuff (common functionality)
button_common = func_button:new({ team = Team.kUnassigned }) 

function button_common:allowed( allowed_entity ) 
	if IsPlayer( allowed_entity ) then
		local player = CastToPlayer( allowed_entity )
		if player:GetTeamId() == self.team and player:IsAlive() then
			return EVENT_ALLOWED
		end
	end

	return EVENT_DISALLOWED
end

-- TODO this doesn't work
function button_common:onfailuse( use_entity )
	if IsPlayer( use_entity ) then
		local player = CastToPlayer( use_entity )
		BroadCastMessageToPlayer( player, "#FF_NOTALLOWEDBUTTON" )
	end
end

-----------------------------------------------------------------------------
-- Button inputs (touch, use, damage etc.)
-----------------------------------------------------------------------------

-- red button
--button_red = button_common:new({ team = Team.kBlue, sec_up = true }) 

button_red = button_common:new({ 
	team = Team.kBlue, 
	sec_up = true, 
	sec_down_icon = "hud_secdown.vtf", 
	sec_up_icon = "hud_secup_red.vtf", 
	iconx = 60,
	icony = 30,
	iconw = 16,
	iconh = 16,
	iconalign = 3
}) 

-----------------------------------------------------------------------------
-- Button responses 
-----------------------------------------------------------------------------
function button_red:onin() 
	BroadCastMessage( "#FF_RED_SECURITY_DEACTIVATED" )
	SpeakAll( "SD_REDDOWN" )

	self.sec_up = false

	RemoveHudItemFromAll( "red-sec-up")
	AddHudIconToAll( self.sec_down_icon, "red-sec-down", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_down", "team", "red")

end 

function button_red:onout()
	BroadCastMessage( "#FF_RED_SECURITY_ACTIVATED" )
	SpeakAll( "SD_REDUP" )

	self.sec_up = true

	RemoveHudItemFromAll( "red-sec-down" )
	AddHudIconToAll( self.sec_up_icon, "red-sec-up", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_up", "team", "red")
	
end

-----------------------------------------------------------------------------
-- Button inputs (touch, use, damage etc.)
-----------------------------------------------------------------------------

-- blue button
--button_blue = button_common:new({ team = Team.kRed, sec_up = true }) 

button_blue = button_common:new({ 
	team = Team.kRed, 
	sec_up = true, 
	sec_down_icon = "hud_secdown.vtf", 
	sec_up_icon = "hud_secup_blue.vtf", 
	iconx = 60,
	icony = 30,
	iconw = 16,
	iconh = 16,
	iconalign = 2
}) 

-----------------------------------------------------------------------------
-- Button responses 
-----------------------------------------------------------------------------
function button_blue:onin() 
	BroadCastMessage( "#FF_BLUE_SECURITY_DEACTIVATED" )
	SpeakAll( "SD_BLUEDOWN" )

	self.sec_up = false

	RemoveHudItemFromAll( "blue-sec-up")
	AddHudIconToAll( self.sec_down_icon, "blue-sec-down", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
	LogLuaEvent(0, 0, "security_down", "team", "blue")

end 

function button_blue:onout()
	BroadCastMessage( "#FF_BLUE_SECURITY_ACTIVATED" )
	SpeakAll( "SD_BLUEUP" )

	self.sec_up = true

	RemoveHudItemFromAll( "blue-sec-down")
	AddHudIconToAll( self.sec_up_icon, "blue-sec-up", self.iconx, self.icony, self.iconw, self.iconh, self.iconalign )
  LogLuaEvent(0, 0, "security_up", "team", "blue")
end

-----------------------------------------------------------------------------
-- Hurts
-----------------------------------------------------------------------------
hurt = trigger_ff_script:new({ team = Team.kUnassigned })
function hurt:allowed( allowed_entity )
	if IsPlayer( allowed_entity ) then
		local player = CastToPlayer( allowed_entity )
		if player:GetTeamId() == self.team then
			return EVENT_ALLOWED
		end
	end

	return EVENT_DISALLOWED
end

-- red lasers hurt blue and vice-versa

red_laser_hurt = hurt:new({ team = Team.kBlue })
blue_laser_hurt = hurt:new({ team = Team.kRed })

-- function precache()
	-- precache sounds	
--	PrecacheSound("vox.blueup")
--	PrecacheSound("vox.bluedown")
--	PrecacheSound("vox.redup")
--	PrecacheSound("vox.reddown")
-- end



-------------------------
-- flaginfo
-------------------------

--flaginfo runs whenever the player spawns or uses the flaginfo command.
--Right now it just refreshes the HUD items; this ensures that players who just joined the server have the right information
function flaginfo( player_entity )
	flaginfo_base(player_entity) --see base_teamplay.lua

	local player = CastToPlayer( player_entity )
	
	RemoveHudItem( player, "red-sec-down" )
	RemoveHudItem( player, "blue-sec-down" )
	RemoveHudItem( player, "red-sec-up" )
	RemoveHudItem( player, "blue-sec-up" )

		if button_blue.sec_up == true then
			AddHudIcon( player, button_blue.sec_up_icon, "blue-sec-up", button_blue.iconx, button_blue.icony, button_blue.iconw, button_blue.iconh, button_blue.iconalign )
		else
			AddHudIcon( player, button_blue.sec_down_icon, "blue-sec-down", button_blue.iconx, button_blue.icony, button_blue.iconw, button_blue.iconh, button_blue.iconalign )
		end

		if button_red.sec_up == true then
			AddHudIcon( player, button_red.sec_up_icon, "red-sec-up", button_red.iconx, button_red.icony, button_red.iconw, button_red.iconh, button_red.iconalign )
		else
			AddHudIcon( player, button_red.sec_down_icon, "red-sec-down", button_red.iconx, button_red.icony, button_red.iconw, button_red.iconh, button_red.iconalign )
		end
end