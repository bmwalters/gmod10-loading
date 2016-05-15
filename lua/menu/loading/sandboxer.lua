sandboxer = {}
local render_calls = {}
local status_calls = {}


local show_debug = true
local messages = {}
local sandbox_env = {}
local first_render_call = true

surface.CreateFont( "Sandboxer_Output", {
	font = "Arcade Interlaced", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 10,
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

function sandboxer.StatusChanged(status)
	for k,v in pairs(status_calls) do 
		if v~=nil then 
			v(status)
		end
	end 
end

function sandboxer.cleanup()
	render_calls = {}
	status_calls = {}
	messages = {}
	show_debug = true 

end

function sandboxer.pushmessage(msg,force_debug)
	MsgC(Color(255,0,0),"Loading Screen Sandbox ") MsgC(Color(255,255,0),msg .. "\n")
	messages[#messages + 1] = msg

	if #messages > 20 then 
		table.remove(messages,1)
	end

	if force_debug==true then 
		show_debug = true 

	end

end


local function parse_script(script)
	local ss,sse = string.find(script,"@SCRIPTSTART")
	local se = string.find(script,"@SCRIPTEND") 
	if !ss then 
		return false,"Script start marker not found."
	end 
	if !se then 
			return false,"Script start marker not found."
	end 
	return true,string.sub(script,sse + 1,se - 1)
end



function sandboxer.sandbox(content)

	local lsfunc = CompileString(content,"Sandboxed Loading Screen Session",false)

	if type(lsfunc)=="string" then 
		sandboxer.pushmessage("ERROR IN LOAD SCRIPT")
		sandboxer.pushmessage("Cannot compile loading script")
		sandboxer.pushmessage(lsfunc)
		return 
	end 

 	setfenv(lsfunc,sandbox_env)
	local s,e = pcall(lsfunc)

	if s~=true then 
		sandboxer.pushmessage("ERROR IN LOAD SCRIPT")
		sandboxer.pushmessage(e)
		show_debug = true 
	end
end



local function sandbox_draw()
	for k,v in pairs(render_calls) do 
		if v~=nil then 

			if first_render_call == true then 
				first_render_call  = false 
				show_debug = false 
			end
			local s,e = pcall(v)
			if s~=true then 
				sandboxer.pushmessage("ERROR IN LOAD RENDER",true)
				sandboxer.pushmessage(e)
			end 
		end
	end	
	local offset = 0 
	for k,v in pairs(messages) do
		if show_debug==true then 
			surface.SetFont("ChatFont")
			surface.SetTextPos(0,offset)
			surface.SetTextColor(Color(255,255,0))
			surface.DrawText(v)
			local w,h = surface.GetTextSize(v)
			offset = offset + h + 1
		end



	end

end 


//hook.Add("DrawOverlay","SandboxDrawStuff",sandbox_draw)



sandboxer.calldraw = sandbox_draw


local function pushrendercall(idx,rnd)
	render_calls[idx] = rnd 
end 

local function pushstatuscall(idx,call)
	status_calls[idx] = call 
end 

// SETUP SANDBOX ENVIRONMENT //
sandbox_env["hookrendercall"] = pushrendercall 
sandbox_env["hookstatuscall"] = pushstatyscall 
sandbox_env["pcall"] = pcall
sandbox_env["draw"] = draw 
sandbox_env["surface"] = surface 
sandbox_env["http"] = http
sandbox_env["PrintTable"] = PrintTable
sandbox_env["print"] = print 
sandbox_env["Lerp"] =  Lerp
sandbox_env["math"] = math 
sandbox_env["SysTime"] = SysTime 
sandbox_env["CurTime"] = CurTime 
sandbox_env["Color"] = Color 
sandbox_env["Material"] = Material 
sandbox_env["table"] = table
sandbox_env["ScrH"] = ScrH
sandbox_env["ScrW"] = ScrW
sandbox_env["pairs"] = pairs
sandbox_env["SortedPairs"] = SortedPairs
sandbox_env["next"] = next 
sandbox_env["ipairs"] = ipairs

//' sandbox_env["render"] = render Unfortunately, we have no render library :(



function sandboxer.GetEnv()
	return table.Copy(sandbox_env)
end

for k,v in pairs(_G) do 
	if string.find(k,"ALIGN") then  
		sandbox_env[k] = v 
	end
end


