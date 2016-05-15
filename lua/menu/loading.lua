local pnlDownloads = vgui.RegisterFile("loading/downloads.lua")

local PANEL = {}

local logloading = true

if logloading then
	if file.Exists("loading_log.txt", "DATA") then
		file.Delete("loading_log.txt")
	end
end

local NumLabels = 10

surface.CreateFont("LoadingProgress", {
	font = "Coolvetica",
	size = 22,
	weight = 500,
})

local color_gray120 = Color(120, 120, 120)

function PANEL:Init()
	self.Downloads = vgui.CreateFromTable(pnlDownloads, self)

	--[[ Using the default progress bar thing for now
	self.Cancel = vgui.Create("DButton", self)
	self.Cancel:SetText("#Cancel")

	function self.Cancel:DoClick() CancelLoading() end
	--]]

	self.Labels = {}

	for i = 1, NumLabels do
		self.Labels[i] = vgui.Create("DLabel", self)
		self.Labels[i]:SetFont("LoadingProgress")
		self.Labels[i]:SetContentAlignment(5)
		self.Labels[i]:SetText("")
		self.Labels[i]:SetTextColor((i == 1) and color_gray120 or Color(120, 120, 120, 127 * (1 - (i / NumLabels))))
	end
end

function PANEL:PerformLayout()
	self:SetSize(ScrW(), ScrH())

	for i = 1, NumLabels do
		self.Labels[i]:SetSize(ScrW(), 24)
		self.Labels[i]:SetPos(0, ScrH() - (24 * (NumLabels + 1 - i)))
	end

	self.Downloads:SetPos(0, 0)
	self.Downloads:SetSize(ScrW(), ScrH() * 0.4)

	-- self.Cancel:AlignRight(50)
	-- self.Cancel:AlignBottom(50)
end

local MatRotate = Material("vgui/loading-rotate")
local MatLogo = Material("vgui/loading-logo")

function PANEL:Paint(w, h)
	surface.SetDrawColor(250, 250, 250, 255)
	surface.DrawRect(0, 0, w, h)

	local matsize = MatLogo:Width()

	local matx, maty = w / 2 - matsize / 2, ScrH() * 0.4

	surface.SetDrawColor(color_white)

	surface.SetMaterial(MatLogo)
	surface.DrawTexturedRect(matx, maty, matsize, matsize)

	surface.SetMaterial(MatRotate)
	surface.DrawTexturedRectRotated(matx + matsize / 2, maty + matsize / 2, matsize, matsize, SysTime() * 180, 0, 0)
end

function PANEL:AddStatusLine(status)
	for i = NumLabels, 2, -1 do
		self.Labels[i]:SetText(self.Labels[i - 1]:GetValue())
	end

	self.Labels[1]:SetText(status)
end

function PANEL:StatusChanged(status)
	-- If it's a file download we do some different stuff..
	if string.find(status, "Downloading ") then
		local filename = string.gsub(status, "Downloading ", "")

		self.Downloads:DownloadingFile(filename)

		self:AddStatusLine("Downloading " .. (TranslateDownloadableName(filename) or filename))

		return
	end

	self.Downloads:StatusChanged(status)

	self:AddStatusLine(status)
end

function PANEL:CheckForStatusChanges()
	local status = GetLoadStatus()
	if not status then return end

	status = string.match(status, "^[ \n\t]*(.-)[ \n\t]*$") -- strip whitespace
	status = string.gsub(status, "[\\/]+", "/") -- normalize slashes
	status = string.gsub(string.gsub(status, ".bz2", ""), ".ztmp", "") -- remove compression extensions

	if self.OldStatus == status then return end

	if logloading then
		file.Append("loading_log.txt", "[" .. os.date("%H:%M:%S", os.time()) .. "]\t" .. status .. "\n")
	end

	self.OldStatus = status
	self:StatusChanged(status)
end

function PANEL:Clean()
	for i = 1, NumLabels do
		self.Labels[i]:SetText("")
	end
	self.Downloads:Clean()
end

function PANEL:OnActivate()
	self:Clean()
end

function PANEL:OnDeactivate()
	self:Clean()
end

function PANEL:Think()
	self:CheckForStatusChanges()
end

local PanelType_Loading = vgui.RegisterTable(PANEL, "EditablePanel") -- todo: can we inherit from Panel instead?

local loadpanel

function GetLoadPanel()
	if not IsValid(loadpanel) then
		loadpanel = vgui.CreateFromTable(PanelType_Loading)
	end

	return loadpanel
end

-- hopefully we load before everyone else so we don't override them; just in case we have gd
local gd = GameDetails
function GameDetails(...)
	if engine.IsPlayingDemo() then return end

	local args = {...}
	for _, str in ipairs(args) do
		MsgN(str)
	end

	if gd then gd(unpack(args)) end
end
