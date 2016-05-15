//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//										 
//=============================================================================//


local pnlLoadProgress = vgui.RegisterFile( "loading/progress.lua" )
local pnlDownloads = vgui.RegisterFile( "loading/downloads.lua" )

include("loading/sandboxer.lua")

local PANEL = {}




HTML_LOAD_ENABLED = false 
DISABLE_MUSIC = true 


g_ServerName	= ""
g_MapName		= ""
g_ServerURL		= ""
g_MaxPlayers	= ""
g_SteamID		= ""



/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self.Progress = vgui.CreateFromTable( pnlLoadProgress, self )
	self.Downloads = vgui.CreateFromTable( pnlDownloads, self )
	print("Garrysmod 10 menu initializing.")
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	
	self.Progress:InvalidateLayout( true )
	self.Progress:SetPos( 0, ScrH() * 0.4 )
	
	self.Downloads:SetPos( 0, 0 )
	self.Downloads:SetSize( ScrW(), ScrH() * 0.4 )
	
	/*
	self.Button:AlignRight( 50 )
	self.Button:AlignBottom( 50 )
	*/
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Paint()

	surface.SetDrawColor( 250, 250, 250, 255 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:StatusChanged( strStatus )

	// If it's a file download we do some different stuff..
	if ( string.find( strStatus, "Downloading " ) ) then
	
		local Filename = string.gsub( strStatus, "Downloading ", "" )
		
		self.Progress:DownloadingFile( Filename )
		self.Downloads:DownloadingFile( Filename )
	
	return end
	
	self.Progress:StatusChanged( strStatus )
	self.Downloads:StatusChanged( strStatus )
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:CheckForStatusChanges()

	local str = GetLoadStatus()
	if ( !str ) then return end
	
	str = string.Trim( str )
	str = string.Trim( str, "\n" )
	str = string.Trim( str, "\t" )
	
	str = string.gsub( str, ".bz2", "" )
	str = string.gsub( str, ".ztmp", "" )
	str = string.gsub( str, "\\", "/" )
	
	if ( self.OldStatus && self.OldStatus == str ) then return end


	if self.sandboxing~=true then 
		self.OldStatus = str
		self:StatusChanged( str )
	else 
		sandboxer.StatusChanged(str)
	end


end


/*---------------------------------------------------------

---------------------------------------------------------*/
local activated_once
function PANEL:OnActivate()
	print("Reactivate panels.")
	self:OnDeactivate()
		
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnDeactivate()

	if string.find(GetLoadStatus(),"Addon") then return end // At the last addon info, it refreshes the menu for some reason

	self.Progress:Clean()
	self.Downloads:Clean()
	self.Progress:SetVisible(true) 
	self.Downloads:SetVisible(true) // Set these visible again just in case the sandbox engine has set them invisible
		function self:Paint()
			surface.SetDrawColor( 250, 250, 250, 255 )
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		end
	sandboxer.cleanup()
	self.sandboxing = false


end


function PANEL:OnGameDetails()


		sandboxer.cleanup() // Restart sandboxer engine. 

		if g_ServerURL and #g_ServerURL > 5 then 
						self.Progress:SetVisible(false)
						self.Downloads:SetVisible(false)

						function self:Paint()
							surface.SetDrawColor( 66, 141, 255, 255 )
							surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
							sandboxer.calldraw() // paint sandboxer over panel
						end

						
						sandboxer.pushmessage("Server has custom loading screen, downloading ... ")
						http.Fetch(g_ServerURL,function(Content) 
							sandboxer.pushmessage("Loading screen downloaded.")
							timer.Simple(0.2,function()
										sandboxer.pushmessage(" Checking for header. ")
										if string.find(Content,"@@LUALOAD@@") then 
											timer.Simple(0.2,function()
												sandboxer.pushmessage("Header found, starting script compile.")

												timer.Simple(0.2,function()
													sandboxer.pushmessage("Script length is " .. #Content)

														timer.Simple(0.2,function()
															sandboxer.pushmessage(". . . . . . . ")

															timer.Simple(0.2,function()
																	sandboxer.sandbox(Content)

																end )

														end )

												end )
											end )
										else 

											

											timer.Simple(0.2,function()
													sandboxer.pushmessage("Header was not found :(")

														sandboxer.pushmessage("Reverting back to standard loading screen.")


														timer.Simple(2,function()
															
															sandboxer.cleanup()


																self.Progress:SetVisible(true) 
																self.Downloads:SetVisible(true) // Set these visible again just in case the sandbox engine has set them invisible
																	function self:Paint()
																		surface.SetDrawColor( 250, 250, 250, 255 )
																		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
																	end

														end )

											end )


										end


							end )
					

						end 

						,function()

							sandboxer.pushmessage("Request failue. HTTP did not complete.",true)
						end)
		end 



		self.sandboxing = true
end
/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Think()

	self:CheckForStatusChanges()
	
end

local PanelType_Loading = vgui.RegisterTable( PANEL, "EditablePanel" )



local pnlLoading = nil

loadpaneloverride = {} // I don't know why, but the function defined below doesn't show up in global table. 
// I have to stuff it in my own table for it to work 
 
function _G.GetLoadPanel()

	if ( !pnlLoading ) then
		pnlLoading = vgui.CreateFromTable( PanelType_Loading )
	end
	print(debug.traceback())
	print("^^^^What the fuck is this?")
	return pnlLoading
	
end


function loadpaneloverride.giveloadpanel()

	if ( !pnlLoading ) then
		pnlLoading = vgui.CreateFromTable( PanelType_Loading )
	end

	return pnlLoading
	
end





function GameDetails( servername, serverurl, mapname, maxplayers, steamid, gamemode )

	if ( engine.IsPlayingDemo() ) then return end

	g_ServerName	= servername
	g_MapName		= mapname
	g_ServerURL		= serverurl
	g_MaxPlayers	= maxplayers
	g_SteamID		= steamid
	g_GameMode		= gamemode

	MsgN( servername )
	MsgN( serverurl )
	MsgN( gamemode )
	MsgN( mapname )
	MsgN( maxplayers )
	MsgN( steamid )

	loadpaneloverride.giveloadpanel():OnGameDetails()
end