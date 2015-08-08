-- Title: Vanilla Consolidate Buffs (VCB)
-- Author: Shino <Synced> - Kronos

-- Global variables
VCB_NAME = "Vanilla Consolidate Buffs"
VCB_VERSION = "2.4"
VCB_IS_LOADED = false
VCB_FONT_ARRAY = {}
VCB_FONT_ARRAY[1] = "FRIZQT__.ttf"
VCB_FONT_ARRAY[2] = "ARIALN.ttf"
VCB_FONT_ARRAY[3] = "skurri.ttf"
VCB_FONT_ARRAY[4] = "MORPHEUS.ttf"
VCB_ANCHOR_ARRAY = {}
VCB_ANCHOR_ARRAY[1] = "Bottom"
VCB_ANCHOR_ARRAY[2] = "Right"
VCB_ANCHOR_ARRAY[3] = "Top"
VCB_ANCHOR_ARRAY[4] = "Left"

--[[
-- VCB_OnLoad()
-- @returns: Void
-- Use: Initialization and registering events
--]]
function VCB_OnLoad()
	this:RegisterEvent("ADDON_LOADED")

	SLASH_VCB1 = "/VanillaConsolidateBuffs"
	SLASH_VCB2 = "/vanillaconsolidatebuffs"
	SLASH_VCB3 = "/VCB"
	SLASH_VCB4 = "/vcb"
	SlashCmdList["VCB"] = function(msg)
		VCB_SlashCommandHandler(msg)
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("VCB "..VCB_VERSION.." is now loaded! Use the command /vcb to configure VCB!")
end

function VCB_OnEvent(event)
	if event == "ADDON_LOADED" and not VCB_IS_LOADED then
		if VCB_SAVE == nil then
			VCB_SAVE = {}
			VCB_SAVE = {
				Timer_hours = false,
				Timer_hours_convert = false,
				Timer_minutes = true,
				Timer_minutes_convert = false,
				Timer_tenth = false,
				Timer_round = false,
				Timer_fontsize = 10, 
				Timer_font = "FRIZQT__.ttf",
				Timer_alpha = 1.0,
				Timer_border = false,
				CF_anchor = 1,
				CF_scale = 1.0,
				CF_invert = false,
				CF_numperrow = 5,
			}
		end
		if VCB_BF_LOCKED == nil then
			VCB_BF_LOCKED = false
		end
		if Consolidated_Buffs == nil then
			Consolidated_Buffs = {}
		end
		if Banned_Buffs == nil then
			Banned_Buffs = {}
		end
		--VCB_SAVE["Timer_alpha"] = 1.0
		--VCB_SAVE["Timer_border"] = false
		--VCB_SAVE["CF_anchor"] = 1
		--VCB_SAVE["CF_scale"] = 1.0
		--VCB_SAVE["CF_invert"] = false
		--VCB_SAVE["CF_numperrow"] = 5
		
		VCB_BF_CONSOLIDATED_BUFFFRAME:ClearAllPoints()
		if VCB_SAVE["CF_anchor"] == 1 then
			VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("TOP", VCB_BF_CONSOLIDATED_ICON, "BOTTOM", 0, 0)
		elseif VCB_SAVE["CF_anchor"] == 2 then
			VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("LEFT", VCB_BF_CONSOLIDATED_ICON, "RIGHT", 0, 0)
		elseif VCB_SAVE["CF_anchor"] == 3 then
			VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("BOTTOM", VCB_BF_CONSOLIDATED_ICON, "TOP", 0, 0)
		else
			VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("RIGHT", VCB_BF_CONSOLIDATED_ICON, "LEFT", 0, 0)
		end
		
		
		VCB_BF_Lock(VCB_BF_LOCKED)
		VCB_IS_LOADED = true
	end	
end

--[[
-- VCB_SlashCommandHandler(string)
-- @returns: Message-Output
-- Use: Handles the incoming commands for VBS and sorts the data to the functions
--]]
function VCB_SlashCommandHandler(msg)
	if(msg) then
		local cmd = string.lower(msg)
		if string.sub(cmd, 1, 5) == "scale" and IsAddOnLoaded("VCB_Buffframe") then
			if string.len(cmd) > 6 then
				local scale = string.sub(cmd, 7, string.len(cmd))
				VCB_BF:Scale(tonumber(scale))
			end
		elseif string.sub(cmd, 1, 6) == "unbuff" and IsAddOnLoaded("VCB_AutoUnbuffer") then
			if string.len(cmd) > 7 then
				local unbuff = string.sub(cmd, 8, string.len(cmd))
				VCB_AU:Unbuff(unbuff)
			end
		else
			VCB_OPTIONS_OnShow()
		end
	end
end

--[[
-- VCB_tablelength(table/array)
-- @return: int
-- Use: Evaluates the length of a table/array for utility use. F. e. for loops.
--]]
function VCB_tablelength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end 
	return count
end

--[[
-- VCB_Contains(table/array, obj)
-- @return: Boolean
-- Use: Evaluates if a table or an array contains a specific value/object for utility use.
--]]
function VCB_Contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

--[[
-- VCB_GetKeys(table/array, obj)
-- @return: int
-- Use: Returns the key of a specific value/object in an table/array for utility use.
--]]
function VCB_GetKeys(a, b)
	local i = 0
	while true do
		if a[i] == b then
			return i
		end
	end
end

--[[
-- VCB_GetKeys(table/array, obj)
-- @return: int
-- Use: Returns the key of a specific value/object in an table/array for utility use.
-- Not sure if I will some up those two functions to improve the performance :/
--]]
function VCB_Table_GetKeys(a, b)
	local i = 1
	while true do
		if a[i] == b then
			return i
		end
		i = i + 1
	end
end

function VCB_EmptyTable(t)
	for k in pairs (t) do
		t [k] = nil
	end
end

function VCB_SendMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFF8080VCB v"..VCB_VERSION..":|r "..msg)
end

---------------------------------------OPTION FRAME BEGIN-----------------------------------------------------------------------------------------------------------------

function VCB_OPTIONS_OnShow()
	if getglobal("VCB_BF_CONSOLIDATED_FRAME"):IsVisible() then
		VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME_Update()
	elseif getglobal("VCB_BF_BANNED_FRAME"):IsVisible() then
		VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME_Update()
	end
	getglobal("VCB_BF_ConfigFrame"):Show()
end

function VCB_OPTIONS_HIDE_ALL()
	getglobal("VCB_BF_CONSOLIDATED_FRAME"):Hide()
	getglobal("VCB_BF_BANNED_FRAME"):Hide()
	getglobal("VCB_BF_TIMER_FRAME"):Hide()
	getglobal("VCB_BF_DBF_COLOR_FRAME"):Hide()
	getglobal("VCB_BF_CF_COLOR_FRAME"):Hide()
	getglobal("VCB_BF_BF_COLOR_FRAME"):Hide()
	getglobal("VCB_BF_CF_FRAME"):Hide()
	getglobal("VCB_BF_BF_FRAME"):Hide()
	getglobal("VCB_BF_DBF_FRAME"):Hide()
	getglobal("VCB_BF_MISC_FRAME"):Hide()
	getglobal("VCB_BF_ABOUT_FRAME"):Hide()
end

function VCB_OPTIONS_SHOW(frame, text)
	getglobal(frame):Show()
	getglobal("VCB_BF_CONFIG_FRAME_TITLE_FONTSTRING"):SetText(text)
	VCB_PAGEINIT(frame)
	PlaySound("igMainMenuOptionCheckBoxOff")
end

function VCB_PAGEINIT(frame)
	if frame == "VCB_BF_TIMER_FRAME" then
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON1"):SetChecked(VCB_SAVE["Timer_hours"])
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON2"):SetChecked(VCB_SAVE["Timer_hours_convert"])
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON3"):SetChecked(VCB_SAVE["Timer_minutes"])
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON4"):SetChecked(VCB_SAVE["Timer_minutes_convert"])
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON5"):SetChecked(VCB_SAVE["Timer_tenth"])
		if VCB_SAVE["Timer_round"] then
			getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON6"):SetChecked(false)
			getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON7"):SetChecked(true)
		else
			getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON6"):SetChecked(true)
			getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON7"):SetChecked(false)
		end
		getglobal("VCB_BF_TIMER_FRAME_SizeSlider"):SetValue(VCB_SAVE["Timer_fontsize"])
		getglobal("VCB_BF_TIMER_FRAME_SizeSliderText"):SetText("Font size: "..VCB_SAVE["Timer_fontsize"]);
		getglobal("VCB_BF_TIMER_FRAME_FontSlider"):SetValue(VCB_Table_GetKeys(VCB_FONT_ARRAY, VCB_SAVE["Timer_font"]))
		getglobal("VCB_BF_TIMER_FRAME_FontSliderText"):SetText("Font: "..VCB_SAVE["Timer_font"]);
		getglobal("VCB_BF_TIMER_FRAME_AlphaSlider"):SetValue(VCB_SAVE["Timer_alpha"])
		getglobal("VCB_BF_TIMER_FRAME_AlphaSliderText"):SetText("Alpha: "..VCB_SAVE["Timer_alpha"]);
		getglobal("VCB_BF_TIMER_FRAME_CHECKBUTTON8"):SetChecked(VCB_SAVE["Timer_border"])
	elseif frame == "VCB_BF_CF_FRAME" then	
		getglobal("VCB_BF_CF_FRAME_AnchorSlider"):SetValue(VCB_SAVE["CF_anchor"])
		getglobal("VCB_BF_CF_FRAME_AnchorSliderText"):SetText("Anchor: "..VCB_ANCHOR_ARRAY[VCB_SAVE["CF_anchor"]]);
		getglobal("VCB_BF_CF_FRAME_ScaleSlider"):SetValue(VCB_SAVE["CF_scale"])
		getglobal("VCB_BF_CF_FRAME_ScaleSliderText"):SetText("Scale: "..VCB_SAVE["CF_scale"]);
		getglobal("VCB_BF_CF_FRAME_CHECKBUTTON1"):SetChecked(VCB_SAVE["CF_invert"])
		getglobal("VCB_BF_CF_FRAME_NumPerRowSlider"):SetValue(VCB_SAVE["CF_numperrow"])
		getglobal("VCB_BF_CF_FRAME_NumPerRowSliderText"):SetText("Buffs per row: "..VCB_SAVE["CF_numperrow"]);
	end
end

function VCB_BF_CHECKBUTTON(obj)
	if (VCB_SAVE[obj]) then
		VCB_SAVE[obj] = false
	else
		VCB_SAVE[obj] = true
	end
end

---------------------------------------START CONSOLIDATED BUFFS FRAME-----------------------------------------------------------------------------------------------------------------

function VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME_Update()
	local line -- 1 through 5 of our window to scroll
	local lineplusoffset -- an index into our data calculated from the scroll offset
	local FRAME = getglobal("VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME")
	FauxScrollFrame_Update(FRAME,VCB_tablelength(Consolidated_Buffs),10,40)
	for line=1,10 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(FRAME)
		if Consolidated_Buffs[lineplusoffset] ~= nil then
			getglobal("VCB_CONSOLIDATED_BUFFS_ENTRY_TEXT"..line):SetText(lineplusoffset..". "..Consolidated_Buffs[lineplusoffset])
			getglobal("VCB_CONSOLIDATED_BUFFS_ENTRY"..line).buff = Consolidated_Buffs[lineplusoffset]
			getglobal("VCB_CONSOLIDATED_BUFFS_ENTRY"..line):Show()
		else
			getglobal("VCB_CONSOLIDATED_BUFFS_ENTRY"..line):Hide()
		end
	end
end

function VCB_CONSOLIDATED_SCROLLFRAME_ENTRY(button)
	getglobal("VCB_BF_CONSOLIDATED_FRAME_LEFT_DELETE_INBOX_TEXT"):SetText(button.buff)
end

function VCB_CONSOLIDATED_BUFFS_DELETE()
	VCB_BF_ConsolidatedRemove(getglobal("VCB_BF_CONSOLIDATED_FRAME_LEFT_DELETE_INBOX_TEXT"):GetText())
	VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME_Update()
end

function VCB_CONSOLIDATED_BUFFS_ADD()
	VCB_BF_ConsolidatedAdd(getglobal("VCB_BF_CONSOLIDATED_FRAME_EditBox"):GetText())
	VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME_Update()
end

function VCB_CONSOLIDATED_BUFFS_REMOVE_ALL()
	VCB_BF_RemoveAllFromConsolidate()
	VCB_BF_CONSOLIDATED_FRAME_RIGHT_SCROLLFRAME_Update()
end

---------------------------------------END CONSOLIDATED BUFFS FRAME-----------------------------------------------------------------------------------------------------------------

---------------------------------------START BANNED BUFFS FRAME-----------------------------------------------------------------------------------------------------------------
function VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME_Update()
	local line -- 1 through 5 of our window to scroll
	local lineplusoffset -- an index into our data calculated from the scroll offset
	local FRAME = getglobal("VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME")
	FauxScrollFrame_Update(FRAME,VCB_tablelength(Banned_Buffs),10,40)
	for line=1,10 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(FRAME)
		if Banned_Buffs[lineplusoffset] ~= nil then
			getglobal("VCB_BANNED_BUFFS_ENTRY_TEXT"..line):SetText(lineplusoffset..". "..Banned_Buffs[lineplusoffset])
			getglobal("VCB_BANNED_BUFFS_ENTRY"..line).buff = Banned_Buffs[lineplusoffset]
			getglobal("VCB_BANNED_BUFFS_ENTRY"..line):Show()
		else
			getglobal("VCB_BANNED_BUFFS_ENTRY"..line):Hide()
		end
	end
end

function VCB_BANNED_SCROLLFRAME_ENTRY(button)
	getglobal("VCB_BF_BANNED_FRAME_LEFT_DELETE_INBOX_TEXT"):SetText(button.buff)
end

function VCB_BANNED_BUFFS_DELETE()
	VCB_BF_RemoveFromBanned(getglobal("VCB_BF_BANNED_FRAME_LEFT_DELETE_INBOX_TEXT"):GetText())
	VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME_Update()
end

function VCB_BANNED_BUFFS_ADD()
	VCB_BF_AddToBanned(getglobal("VCB_BF_BANNED_FRAME_EditBox"):GetText())
	VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME_Update()
end

function VCB_BANNED_BUFFS_REMOVE_ALL()
	VCB_BF_RemoveAllFromBanned()
	VCB_BF_BANNED_FRAME_RIGHT_SCROLLFRAME_Update()
end

---------------------------------------END BANNED BUFFS FRAME-----------------------------------------------------------------------------------------------------------------
---------------------------------------START TIMER FRAME-----------------------------------------------------------------------------------------------------------------
function VCB_BF_CHECKBUTTON_TIMER_HOURS()
	if not VCB_SAVE["Timer_hours"] then
		VCB_SAVE["Timer_hours"] = true
		VCB_BF_TIMER_FRAME_CHECKBUTTON3:SetChecked(true)
		VCB_SAVE["Timer_minutes"] = true
	else
		VCB_SAVE["Timer_hours"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON2:SetChecked(false)
		VCB_SAVE["Timer_hours_convert"] = false
	end
end

function VCB_BF_CHECKBUTTON_TIMER_HOURS_CONVERT()
	if not VCB_SAVE["Timer_hours_convert"] then
		VCB_SAVE["Timer_hours_convert"] = true
		VCB_BF_TIMER_FRAME_CHECKBUTTON1:SetChecked(true)
		VCB_SAVE["Timer_hours"] = true
		VCB_BF_TIMER_FRAME_CHECKBUTTON3:SetChecked(true)
		VCB_SAVE["Timer_minutes"] = true
	else
		VCB_SAVE["Timer_hours_convert"] = false
	end
end

function VCB_BF_CHECKBUTTON_TIMER_MINUTES()
	if not VCB_SAVE["Timer_minutes"] then
		VCB_SAVE["Timer_minutes"] = true
	else
		VCB_SAVE["Timer_minutes"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON1:SetChecked(false)
		VCB_SAVE["Timer_hours"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON2:SetChecked(false)
		VCB_SAVE["Timer_hours_convert"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON4:SetChecked(false)
		VCB_SAVE["Timer_minutes_convert"] = false
	end
end

function VCB_BF_CHECKBUTTON_TIMER_MINUTES_CONVERT()
	if not VCB_SAVE["Timer_minutes_convert"] then
		VCB_SAVE["Timer_minutes_convert"] = true
		VCB_BF_TIMER_FRAME_CHECKBUTTON3:SetChecked(true)
		VCB_SAVE["Timer_minutes"] = true
	else
		VCB_SAVE["Timer_minutes_convert"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON1:SetChecked(false)
		VCB_SAVE["Timer_hours"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON2:SetChecked(false)
		VCB_SAVE["Timer_hours_convert"] = false
	end
end

function VCB_BF_CHECKBUTTON_ROUND()
	if VCB_SAVE["Timer_round"] then
		VCB_SAVE["Timer_round"] = false
		VCB_BF_TIMER_FRAME_CHECKBUTTON7:SetChecked(false)
	else
		VCB_SAVE["Timer_round"] = true
		VCB_BF_TIMER_FRAME_CHECKBUTTON6:SetChecked(false)
	end
end

function VCB_BF_CHECKBUTTON_TIMER_BORDER()
	if VCB_SAVE["Timer_border"] then
		VCB_SAVE["Timer_border"] = false
	else
		VCB_SAVE["Timer_border"] = true
	end
	for cat, tname in pairs(VCB_BUTTONNAME) do
		for i=VCB_MININDEX[cat], VCB_MAXINDEX[cat] do
			if VCB_SAVE["Timer_border"] then
				getglobal(tname..i.."Duration"):SetFont("Fonts\\"..VCB_SAVE["Timer_font"], VCB_SAVE["Timer_fontsize"], "OUTLINE")
			else
				getglobal(tname..i.."Duration"):SetFont("Fonts\\"..VCB_SAVE["Timer_font"], VCB_SAVE["Timer_fontsize"])
			end
		end
	end
end

function VCB_BF_TIMER_FRAME_SizeSliderChange(obj)
	VCB_SAVE["Timer_fontsize"] = obj:GetValue()
	getglobal("VCB_BF_TIMER_FRAME_SizeSliderText"):SetText("Font size: "..VCB_SAVE["Timer_fontsize"]);
	for cat, tname in pairs(VCB_BUTTONNAME) do
		for i=VCB_MININDEX[cat], VCB_MAXINDEX[cat] do
			local p = 1
			if getglobal(tname..i):GetParent() == VCB_BF_CONSOLIDATED_BUFFFRAME then
				p = VCB_SAVE["CF_scale"]
			end
			getglobal(tname..i.."Duration"):SetFont("Fonts\\"..VCB_SAVE["Timer_font"], p*VCB_SAVE["Timer_fontsize"])
		end
	end
end

function VCB_BF_TIMER_FRAME_FontSliderChange(obj)
	VCB_SAVE["Timer_font"] = VCB_FONT_ARRAY[obj:GetValue()]
	getglobal("VCB_BF_TIMER_FRAME_FontSliderText"):SetText("Font: "..VCB_SAVE["Timer_font"]);
	for cat, tname in pairs(VCB_BUTTONNAME) do
		for i=VCB_MININDEX[cat], VCB_MAXINDEX[cat] do
			local p = 1
			if getglobal(tname..i):GetParent() == VCB_BF_CONSOLIDATED_BUFFFRAME then
				p = VCB_SAVE["CF_scale"]
			end
			getglobal(tname..i.."Duration"):SetFont("Fonts\\"..VCB_SAVE["Timer_font"], p*VCB_SAVE["Timer_fontsize"])
		end
	end
end

function VCB_BF_TIMER_FRAME_AlphaSliderChange(obj)
	VCB_SAVE["Timer_alpha"] = string.format("%.1f", obj:GetValue())
	getglobal("VCB_BF_TIMER_FRAME_AlphaSliderText"):SetText("Alpha: "..VCB_SAVE["Timer_alpha"]);
	for cat, tname in pairs(VCB_BUTTONNAME) do
		for i=VCB_MININDEX[cat], VCB_MAXINDEX[cat] do
			getglobal(tname..i.."Duration"):SetAlpha(VCB_SAVE["Timer_alpha"])
		end
	end
end

---------------------------------------END TIMER FRAME-----------------------------------------------------------------------------------------------------------------
---------------------------------------START CONSOLIDATED FRAME-----------------------------------------------------------------------------------------------------------------

function VCB_BF_CF_FRAME_AnchorSliderChange(obj)
	VCB_SAVE["CF_anchor"] = obj:GetValue()
	getglobal("VCB_BF_CF_FRAME_AnchorSliderText"):SetText("Anchor: "..VCB_ANCHOR_ARRAY[VCB_SAVE["CF_anchor"]]);
	VCB_BF_CONSOLIDATED_BUFFFRAME:ClearAllPoints()
	if VCB_SAVE["CF_anchor"] == 1 then
		VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("TOP", VCB_BF_CONSOLIDATED_ICON, "BOTTOM", 0, 0)
	elseif VCB_SAVE["CF_anchor"] == 2 then
		VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("LEFT", VCB_BF_CONSOLIDATED_ICON, "RIGHT", 0, 0)
	elseif VCB_SAVE["CF_anchor"] == 3 then
		VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("BOTTOM", VCB_BF_CONSOLIDATED_ICON, "TOP", 0, 0)
	else
		VCB_BF_CONSOLIDATED_BUFFFRAME:SetPoint("RIGHT", VCB_BF_CONSOLIDATED_ICON, "LEFT", 0, 0)
	end
end

function VCB_BF_CF_FRAME_ScaleSliderChange(obj)
	VCB_SAVE["CF_scale"] = string.format("%.1f", obj:GetValue())
	getglobal("VCB_BF_CF_FRAME_ScaleSliderText"):SetText("Scale: "..VCB_SAVE["CF_scale"]);
	VCB_BF_RepositioningAndResizing()
end

function VCB_BF_CF_FRAME_INVERTBUTTON()
	if VCB_SAVE["CF_invert"] then
		VCB_SAVE["CF_invert"] = false
	else
		VCB_SAVE["CF_invert"] = true
	end
	VCB_BF_RepositioningAndResizing()
end

function VCB_BF_CF_FRAME_NumPerRowSliderChange(obj)
	VCB_SAVE["CF_numperrow"] = obj:GetValue()
	getglobal("VCB_BF_CF_FRAME_NumPerRowSliderText"):SetText("Buffs per row: "..VCB_SAVE["CF_numperrow"]);
	VCB_BF_RepositioningAndResizing()
end

---------------------------------------END CONSOLIDATED FRAME-----------------------------------------------------------------------------------------------------------------