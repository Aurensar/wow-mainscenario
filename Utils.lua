local addonName, MS = ...
MS.title = GetAddOnMetadata(addonName, "Title")

StaticPopupDialogs["MAINSCENARIO_EXTERNALCONTENT"] = {
	text = "Copy the video URL below:",
	button1 = "Done",
	OnAccept = function() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	hasEditBox = true,
	editBoxWidth = 350,
  }

local debugEnabled = true
local i = 0
function MS:Log(strName, tData) 
    if ViragDevTool_AddData and debugEnabled then 
		ViragDevTool_AddData(tData, "MS "..i.." "..strName) 
		i = i + 1
    end
end