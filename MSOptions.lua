local addonName, MS = ...
MS.forcedUpdate = false

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
local _DBG = function(...) if _DBG then _DBG("MS", ...) end end

-- Lua API
local floor = math.floor
local fmod = math.fmod
local format = string.format
local ipairs = ipairs
local pairs = pairs
local strlen = string.len
local strsub = string.sub

local db, dbChar
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
local anchors = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }
local strata = { "LOW", "MEDIUM", "HIGH" }
local flags = { [""] = "None", ["OUTLINE"] = "Outline", ["OUTLINE, MONOCHROME"] = "Outline Monochrome" }
local textures = { "None", "Default (Blizzard)", "One line", "Two lines" }
local modifiers = { [""] = "None", ["ALT"] = "Alt", ["CTRL"] = "Ctrl", ["ALT-CTRL"] = "Alt + Ctrl" }

local cTitle = " "..NORMAL_FONT_COLOR_CODE
local cBold = "|cff00ffe3"
local cWarning = "|cffff7f00"
local beta = "|cffff7fff[Beta]|r"
local warning = cWarning.."Warning:|r UI will be re-loaded!"

local MSF = MS.frame

local overlay
local overlayShown = false

local OverlayFrameUpdate, OverlayFrameHide, GetModulesOptionsTable, MoveModule, SetSharedColor	-- functions

local defaults = {
	profile = {
		anchorPoint = "TOPRIGHT",
		xOffset = -500,
		yOffset = -50,
		maxHeight = 400,
		frameScrollbar = true,
		frameStrata = "LOW",
		
		bgr = "Solid",
		bgrColor = { r=0, g=0, b=0, a=0.7 },
		border = "None",
		borderColor = { r=1, g=0.82, b=0 },
		borderAlpha = 1,
		borderThickness = 16,
		bgrInset = 4,
		progressBar = "Blizzard",

		font = LSM:GetDefault("font"),
		fontSize = 12,
		fontFlag = "",
		fontShadow = 1,
		colorDifficulty = false,
		textWordWrap = false,
		objNumSwitch = false,

		hdrBgr = 2,
		hdrBgrColor = { r=1, g=0.82, b=0 },
		hdrBgrColorShare = false,
		hdrTxtColor = { r=1, g=0.82, b=0 },
		hdrTxtColorShare = false,
		hdrBtnColor = { r=1, g=0.82, b=0 },
		hdrBtnColorShare = false,
		hdrQuestsTitleAppend = true,
		hdrAchievsTitleAppend = true,
		hdrPetTrackerTitleAppend = true,
		hdrCollapsedTxt = 3,
		hdrOtherButtons = true,
		keyBindMinimize = "",
		
		qiBgrBorder = false,
		qiXOffset = -5,
		qiActiveButton = true,
		qiActiveButtonBindingShow = true,

		hideEmptyTracker = false,
		collapseInInstance = false,
		tooltipShow = true,
		tooltipShowRewards = true,
		tooltipShowID = true,
        menuWowheadURL = true,
        menuWowheadURLModifier = "ALT",
        questDefaultActionMap = false,
		questShowTags = true,

		messageQuest = true,
		messageAchievement = true,
		sink20OutputSink = "UIErrorsFrame",
		sink20Sticky = false,
		soundQuest = true,
		soundQuestComplete = "KT - Default",

		modulesOrder = {
			"SCENARIO_CONTENT_TRACKER_MODULE",
			"UI_WIDGET_TRACKER_MODULE",
			"AUTO_QUEST_POPUP_TRACKER_MODULE",
			"QUEST_TRACKER_MODULE",
			"BONUS_OBJECTIVE_TRACKER_MODULE",
			"WORLD_QUEST_TRACKER_MODULE",
			"ACHIEVEMENT_TRACKER_MODULE"
		},

		addonMasque = false,
		addonPetTracker = false,
		addonTomTom = false,
	},
	char = {
		collapsed = false,
	}
}

local options = {
	name = "MainScenario",
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		general = {
			name = "Options",
			type = "group",
			args = {
				sec0 = {
					name = "Info",
					type = "group",
					inline = true,
					order = 0,
					args = {
						version = {
							name = " |cffffd100Version:|r  "..MS.version,
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 0.11,
						},
						build = {
							name = " |cffffd100Build:|r  Retail",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 0.12,
						},
						slashCmd = {
							name = cBold.." /ms|r  |cff808080...............|r  Toggle the story guidance window\n"..
									cBold.." /ms config|r  |cff808080...|r  Show this config window\n",
							type = "description",
							width = "double",
							order = 0.3,
						},
						news = {
							name = "What's New",
							type = "execute",
							disabled = function()
								return true
							end,
							func = function()
							end,
							order = 0.2,
						},
						help = {
							name = "Help",
							type = "execute",
							disabled = function()
								return true
							end,
							func = function()
							end,
							order = 0.4,
						},
					},
				},
				sec1 = {
					name = "Position / Size",
					type = "group",
					inline = true,
					order = 1,
					args = {
						xOffset = {
							name = "X offset",
							desc = "- Default: "..defaults.profile.xOffset.."\n- Step: 1",
							type = "range",
							min = 0,
							max = 0,
							step = 1,
							set = function(_, value)
								db.xOffset = value
								MS:MoveStoryFrame()
							end,
							order = 1.2,
						},
						yOffset = {
							name = "Y offset",
							desc = "- Default: "..defaults.profile.yOffset.."\n- Step: 2",
							type = "range",
							min = 0,
							max = 0,
							step = 2,
							set = function(_, value)
								db.yOffset = value
								MS:MoveStoryFrame()
								OverlayFrameUpdate()
							end,
							order = 1.3,
						},
						maxHeightShowOverlay = {
							name = "Show Max. height overlay",
							desc = "Show overlay, for better visualisation Max. height value.",
							type = "toggle",
							width = 1.3,
							get = function()
								return overlayShown
							end,
							set = function()
								overlayShown = not overlayShown
								if overlayShown and not overlay then
									overlay = CreateFrame("Frame", MSF:GetName().."Overlay", MSF)
									overlay:SetFrameLevel(MSF:GetFrameLevel() + 11)
									overlay.texture = overlay:CreateTexture(nil, "BACKGROUND")
									overlay.texture:SetAllPoints()
									overlay.texture:SetColorTexture(0, 1, 0, 0.3)
									OverlayFrameUpdate()
								end
								overlay:SetShown(overlayShown)
							end,
							order = 1.5,
						},
						maxHeightNote = {
							name = cBold.."\n Max. height is related with value Y offset.\n"..
								" Content is lesser ... tracker height is automatically increases.\n"..
								" Content is greater ... tracker enables scrolling.",
							type = "description",
							order = 1.6,
						},
						frameScrollbar = {
							name = "Show scroll indicator",
							desc = "Show scroll indicator when srolling is enabled. Color is shared with border.",
							type = "toggle",
							set = function()
								db.frameScrollbar = not db.frameScrollbar
								KTF.Bar:SetShown(db.frameScrollbar)
								KT:SetSize()
							end,
							order = 1.7,
						},
						frameStrata = {
							name = "Strata",
							desc = "- Default: "..defaults.profile.frameStrata,
							type = "select",
							values = strata,
							get = function()
								for k, v in ipairs(strata) do
									if db.frameStrata == v then
										return k
									end
								end
							end,
							set = function(_, value)
								db.frameStrata = strata[value]
								KTF:SetFrameStrata(strata[value])
								KTF.Buttons:SetFrameStrata(strata[value])
							end,
							order = 1.8,
						},
					},
				},
				sec2 = {
					name = "Background / Border",
					type = "group",
					inline = true,
					order = 2,
					args = {
						bgr = {
							name = "Background texture",
							type = "select",
							dialogControl = "LSM30_Background",
							values = WidgetLists.background,
							set = function(_, value)
								db.bgr = value
								MS:SetBackground()
							end,
							order = 2.1,
						},
						bgrColor = {
							name = "Background color",
							type = "color",
							hasAlpha = true,
							get = function()
								return db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a
							end,
							set = function(_, r, g, b, a)
								db.bgrColor.r = r
								db.bgrColor.g = g
								db.bgrColor.b = b
								db.bgrColor.a = a
								MS:SetBackground()
							end,
							order = 2.2,
						},
						bgrNote = {
							name = cBold.." For a custom background\n texture set white color.",
							type = "description",
							width = "normal",
							order = 2.21,
						},
						border = {
							name = "Border texture",
							type = "select",
							dialogControl = "LSM30_Border",
							values = WidgetLists.border,
							set = function(_, value)
								db.border = value
								MS:SetBackground()
							end,
							order = 2.3,
						},
						borderColor = {
							name = "Border color",
							type = "color",
							get = function()
								return db.borderColor.r, db.borderColor.g, db.borderColor.b
							end,
							set = function(_, r, g, b)
								db.borderColor.r = r
								db.borderColor.g = g
								db.borderColor.b = b
								MS:SetBackground()
								MS:SetText()
								SetSharedColor(db.borderColor)
							end,
							order = 2.4,
						},
						borderAlpha = {
							name = "Border transparency",
							desc = "- Default: "..defaults.profile.borderAlpha.."\n- Step: 0.05",
							type = "range",
							min = 0.1,
							max = 1,
							step = 0.05,
							set = function(_, value)
								db.borderAlpha = value
								MS:SetBackground()
							end,
							order = 2.6,
						},
						borderThickness = {
							name = "Border thickness",
							desc = "- Default: "..defaults.profile.borderThickness.."\n- Step: 0.5",
							type = "range",
							min = 1,
							max = 24,
							step = 0.5,
							set = function(_, value)
								db.borderThickness = value
								MS:SetBackground()
							end,
							order = 2.7,
						},
						bgrInset = {
							name = "Background inset",
							desc = "- Default: "..defaults.profile.bgrInset.."\n- Step: 0.5",
							type = "range",
							min = 0,
							max = 10,
							step = 0.5,
							set = function(_, value)
								db.bgrInset = value
								MS:SetBackground()
							end,
							order = 2.8,
						},
						progressBar = {
							name = "Progress bar texture",
							type = "select",
							dialogControl = "LSM30_Statusbar",
							values = WidgetLists.statusbar,
							set = function(_, value)
								db.progressBar = value
								MS:SetStoryPartFramesDisplayConfiguration()
							end,
							order = 2.9,
						},
					},
				},
				sec3 = {
					name = "Texts",
					type = "group",
					inline = true,
					order = 3,
					args = {
						font = {
							name = "Font",
							type = "select",
							dialogControl = "LSM30_Font",
							values = WidgetLists.font,
							set = function(_, value)
								db.font = value
								KT.forcedUpdate = true
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:Update()
								end
								KT.forcedUpdate = false
							end,
							order = 3.1,
						},
						fontSize = {
							name = "Font size",
							type = "range",
							min = 8,
							max = 24,
							step = 1,
							set = function(_, value)
								db.fontSize = value
								KT.forcedUpdate = true
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:Update()
								end
								KT.forcedUpdate = false
							end,
							order = 3.2,
						},
						fontFlag = {
							name = "Font flag",
							type = "select",
							values = flags,
							get = function()
								for k, v in pairs(flags) do
									if db.fontFlag == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.fontFlag = value
								KT.forcedUpdate = true
								KT:SetText()
								ObjectiveTracker_Update()
								if PetTracker then
									PetTracker.Objectives:Update()
								end
								KT.forcedUpdate = false
							end,
							order = 3.3,
						},
						fontShadow = {
							name = "Font shadow",
							desc = warning,
							type = "toggle",
							confirm = true,
							confirmText = warning,
							get = function()
								return (db.fontShadow == 1)
							end,
							set = function(_, value)
								db.fontShadow = value and 1 or 0
								ReloadUI()	-- WTF
							end,
							order = 3.4,
						},
						colorDifficulty = {
							name = "Color by difficulty",
							desc = "Quest titles color by difficulty.",
							type = "toggle",
							set = function()
								db.colorDifficulty = not db.colorDifficulty
								ObjectiveTracker_Update()
								QuestMapFrame_UpdateAll()
							end,
							order = 3.5,
						},
						textWordWrap = {
							name = "Wrap long texts",
							desc = "Long texts shows on two lines or on one line with ellipsis (...).",
							type = "toggle",
							set = function()
								db.textWordWrap = not db.textWordWrap
								KT.forcedUpdate = true
								ObjectiveTracker_Update()
								ObjectiveTracker_Update()
								KT.forcedUpdate = false
							end,
							order = 3.6,
						},
					},
				},
			},
		},
	},
}

local general = options.args.general.args

function MS:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame.general)
end

function MS:InitProfile(event, database, profile)
	ReloadUI()
end

function MS:SetupOptions()

	MS:Log("SetupOptions", nil)

	self.db = LibStub("AceDB-3.0"):New(addonName.."DB", defaults, true)
	self.options = options
	db = self.db.profile
	dbChar = self.db.char

	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profiles.confirm = true
	options.args.profiles.args.reset.confirmText = warning
	options.args.profiles.args.new.confirmText = warning
	options.args.profiles.args.choose.confirmText = warning
	options.args.profiles.args.copyfrom.confirmText = warning

	ACR:RegisterOptionsTable(addonName, options, nil)
	
	self.optionsFrame = {}
	self.optionsFrame.general = ACD:AddToBlizOptions(addonName, self.title, nil, "general")
	self.optionsFrame.profiles = ACD:AddToBlizOptions(addonName, options.args.profiles.name, self.title, "profiles")

	self.db.RegisterCallback(self, "OnProfileChanged", "InitProfile")
	self.db.RegisterCallback(self, "OnProfileCopied", "InitProfile")
	self.db.RegisterCallback(self, "OnProfileReset", "InitProfile")
end

MS.settings = {}
InterfaceOptionsFrame:HookScript("OnHide", function(self)
	for k, v in pairs(MS.settings) do
		if strfind(k, "Save") then
			MS.settings[k] = false
		else
			db[k] = v
		end
	end
	ACR:NotifyChange(addonName)

	OverlayFrameHide()
end)

hooksecurefunc("OptionsList_SelectButton", function(listFrame, button)
	OverlayFrameHide()
end)

function OverlayFrameUpdate()
	if overlay then
		overlay:SetSize(280, db.maxHeight)
		overlay:ClearAllPoints()
		overlay:SetPoint(db.anchorPoint, 0, 0)
	end
end

function OverlayFrameHide()
	if overlayShown then
		overlay:Hide()
		overlayShown = false
	end
end

function SetSharedColor(color)
	--local name = "Use border |cff"..MS.RgbToHex(color).."color|r"
	--local sec4 = general.sec4.args
	--sec4.hdrBgrColorShare.name = name
	--sec4.hdrTxtColorShare.name = name
	--sec4.hdrBtnColorShare.name = name
end