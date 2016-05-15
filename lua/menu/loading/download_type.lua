//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//										 
//=============================================================================//




surface.CreateFont( "LoadingDownloads", {
	font = "Coolvetica", 
	size = 20, 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
} )



PANEL.Base = "Panel"

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self.Icon = vgui.Create( "DImage", self )
	self.Icon:SetImage( "gui/silkicons/page_white_magnify" )

	self.lblNumToDownload = vgui.Create( "DLabel", self )
	self.lblNumToDownload:SetContentAlignment( 4 )
	self.lblNumToDownload:SetFont( "LoadingDownloads" )

	self.Files = {}
	self.FilesToDownload = {}
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()
	
	local Height = 20
	
	self:SetWide( 150 )
	self:SetTall( Height )
	
	self.Icon:SetPos( 0, 0 )
	self.Icon:SizeToContents()
	self.Icon:CenterVertical()
	
	self.lblNumToDownload:StretchToParent( 25, 0, 0, 0 )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetText( txt )

	self.TypeName = txt

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetIcon( txt )

	self.IconTexture = txt
	self.Icon:SetImage( txt )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetSpeed( s )

	self.Speed = s

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:AddFile( filename )

	local iReturn = 0
	local bExists = file.Exists( filename, "MOD" )
	if ( bExists ) then
	
		table.insert( self.Files, filename )
	
	else
	
		table.insert( self.FilesToDownload, filename )
		iReturn = 1
	
	end

	self:UpdateCounts()
	return iReturn
	
end

/*---------------------------------------------------------
	If the filename is in our list, move it to downloaded.
---------------------------------------------------------*/
function PANEL:Downloaded( filename )

	for k, v in pairs( self.FilesToDownload ) do
	
		if ( v == filename ) then
			
			self.FilesToDownload[ k ] = nil
			table.insert( self.Files, v )
			
		end
	
	end

	self:UpdateCounts()

end

/*---------------------------------------------------------
	If the filename is in our list, move it to downloaded.
---------------------------------------------------------*/
function PANEL:MakeRunner( filename )

	for k, v in pairs( self.FilesToDownload ) do

		// Fix the filename
		v = string.gsub( v, "\\", "/" )

		if ( v == filename ) then
			
			return self:GetParent():AddRunner( self.IconTexture, self.Speed )
			
		end
	
	end
	
	

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:ShouldBeVisible()

	return table.Count( self.FilesToDownload ) > 0

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:UpdateCounts()

	local cnt = table.Count( self.FilesToDownload ) 
	self.lblNumToDownload:SetText( Format( "%i %s", cnt, self.TypeName ) )
	
	if ( cnt == 0 ) then 
		self:SetVisible( false )
	end

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Clean()

	self.Files = {}
	self.FilesToDownload = {}
	
	self:UpdateCounts()

end

