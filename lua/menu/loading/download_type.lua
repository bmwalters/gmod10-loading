local pnlRunnerType = vgui.RegisterFile("runner.lua")

surface.CreateFont("LoadingDownloads", {
	font = "Coolvetica",
	size = 20,
	weight = 500,
})

PANEL.Base = "Panel"

function PANEL:Init()
	self.icon = vgui.Create("DImage", self)
	self.icon:SetImage("icon16/help.png")

	self.label = vgui.Create("DLabel", self)
	self.label:SetContentAlignment(4)
	self.label:SetFont("LoadingDownloads")

	self.Files = {}
	self.FilesToDownload = {}

	self.NumFilesRemaining = 0
end

function PANEL:PerformLayout()
	self:SetSize(150, 20)

	self.icon:SetPos(0, 0)
	self.icon:SizeToContents()
	self.icon:CenterVertical()

	self.label:StretchToParent(25, 0, 0, 0)
end

function PANEL:SetText(txt)
	self.TypeName = txt
	self:UpdateLabel()
end

function PANEL:SetIcon(txt)
	self.icon:SetImage(txt)
end

function PANEL:SetSpeed(s)
	self.Speed = s
end

function PANEL:AddFile(filename)
	local iReturn = 0
	local exists = file.Exists(filename, "MOD")
	if exists then
		self.Files[#self.Files + 1] = filename
	else
		self.FilesToDownload[#self.FilesToDownload + 1] = filename
		self.NumFilesRemaining = self.NumFilesRemaining + 1
		iReturn = 1
	end

	self:UpdateLabel()

	return iReturn
end

-- If the filename is in our list, move it to downloaded.
function PANEL:Downloaded(filename)
	for k, v in pairs(self.FilesToDownload) do
		if v == filename then
			self.FilesToDownload[k] = nil
			self.Files[#self.Files + 1] = v
			self.NumFilesRemaining = self.NumFilesRemaining - 1

			self:UpdateLabel()

			return
		end
	end
end

function PANEL:MakeRunner(filename)
	for _, v in pairs(self.FilesToDownload) do
		if v == filename then
			local runner = vgui.CreateFromTable(pnlRunnerType, self:GetParent())
			runner:SetUp(self.icon:GetImage(), self.Speed)
			return runner
		end
	end
end

function PANEL:ShouldBeVisible()
	return self.NumFilesRemaining > 0
end

function PANEL:UpdateLabel()
	self.label:SetText(string.format("%i %s", self.NumFilesRemaining, self.TypeName))

	if not self:ShouldBeVisible() then
		self:SetVisible(false)
	end
end

function PANEL:Clean()
	self.Files = {}
	self.FilesToDownload = {}
	self.NumFilesRemaining = 0

	self:UpdateLabel()
end
