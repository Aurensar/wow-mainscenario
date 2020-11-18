local addonName, addon = ...
local MS = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "LibSink-2.0")
MS:SetDefaultModuleState(false)
MS.title = GetAddOnMetadata(addonName, "Title")
MS.version = GetAddOnMetadata(addonName, "Version")
MS.gameVersion = GetBuildInfo()
MS.locale = GetLocale()
MS.StoryData = {}

local LSM = LibStub("LibSharedMedia-3.0")

-- Lua API
local abs = math.abs
local floor = math.floor
local fmod = math.fmod
local format = string.format
local gsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local strfind = string.find
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local unpack = unpack
local round = function(n) return floor(n + 0.5) end

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent

local trackerWidth = 400
local msgPatterns = {}
local combatLockdown = false
local db, dbChar

-- Main frame
local MSF = CreateFrame("Frame", addonName.."Frame", UIParent, "BackdropTemplate")
MSF.PartFrames = {}
MSF.UnusedPartFrames = { }
MS.frame = MSF

local function SlashHandler(msg, editbox)
	local cmd, value = msg:match("^(%S*)%s*(.-)$")
	if cmd == "config" then
		MS:OpenOptions()
	elseif cmd == "hide" then
		MSF:Hide()
	elseif cmd == "show" then
		MSF:Show()
	end
end

-- Setup ---------------------------------------------------------------------------------------------------------------

local function Init()
	MS:Log("Init", true)
	db = MS.db.profile
	MS:MoveStoryFrame()
	MS:SetBackground()
	MS:SetStoryPartFramesDisplayConfiguration()
	MS.inWorld = true
end

-- Frames --------------------------------------------------------------------------------------------------------------

function MS:StopMoveFrame()
	point, relativeTo, relativePoint, xOfs, yOfs = MSF:GetPoint()
	MS:Log(string.format("%s %d %d", point, xOfs, yOfs))
	db.xOffset = xOfs
	db.yOffset = yOfs
	MSF:StopMovingOrSizing()
end

local function CreateStaticFrames()
	-- Main frame
	MSF:SetWidth(trackerWidth)
	MSF:SetFrameStrata(db.frameStrata)
	MSF:SetFrameLevel(MSF:GetFrameLevel() + 25)
	MSF:Show()
	MSF:SetMovable(true)
	MSF:EnableMouse(true)
	MSF:RegisterForDrag("LeftButton")
	MSF:SetScript("OnDragStart", MSF.StartMoving)
	MSF:SetScript("OnDragStop", MS.StopMoveFrame)

	MSF:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
		MS:Log(string.format("%s %s %s %s", event, tostring(arg1), tostring(arg2), tostring(arg3)))
		if event == "PLAYER_ENTERING_WORLD" then
			MS.inWorld = true
			if not MS.initialized then
				Init()
			end
		elseif event == "QUEST_WATCH_LIST_CHANGED" then
		elseif event == "QUEST_AUTOCOMPLETE" then
		elseif event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
			MS:HandleQuestAcceptedOrAbandoned(arg1)
		elseif event == "QUEST_TURNED_IN" then
			MS:HandleQuestTurnedIn(arg1)
		elseif event == "ACHIEVEMENT_EARNED" then		
			MS:HandleAchievementCompleted(arg1)
		elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then	
		elseif event == "PLAYER_LEVEL_UP" then		
			MS:HandleLevelUp(arg1)
		elseif event == "GOSSIP_SHOW" then		
			--local title1, level1, isTrivial1, frequency1, isRepeatable1, isLegendary1, isIgnored1, questID1, ... = GetGossipAvailableQuests()
			--MS:Log("GOSSIP_SHOW", GetGossipAvailableQuests())
			-- Use this to warn players about accepting quests that are ahead in the story
		end
	end)
	MSF:RegisterEvent("PLAYER_ENTERING_WORLD")
	MSF:RegisterEvent("QUEST_AUTOCOMPLETE")
	MSF:RegisterEvent("QUEST_ACCEPTED")
	MSF:RegisterEvent("QUEST_REMOVED")
	MSF:RegisterEvent("ACHIEVEMENT_EARNED")
	MSF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	MSF:RegisterEvent("ZONE_CHANGED")
	MSF:RegisterEvent("PLAYER_LEVEL_UP")
	MSF:RegisterEvent("GOSSIP_SHOW")
	MSF:RegisterEvent("QUEST_TURNED_IN")
	MSF:RegisterEvent("QUEST_DATA_LOAD_RESULT")
	
	-- Header frame
	local header = CreateFrame("Frame", addonName.."Header", MSF, "MS_Header")
	header:SetPoint("TOPLEFT", 0, 0)
	header:Show()
	MSF.Header = header
	if MS.ActiveStory then
		MSF.Header.AddonTitle:SetText(string.format("MainScenario: %s", MS.ActiveStory.Title))
	else
		MSF.Header.AddonTitle:SetText(string.format("MainScenario: No active story"))
	end
	MSF:SetHeight(header:GetHeight())

	MS:SetupContentFrame()
end

function MS:HandleLevelUp(level)
	MS.playerLevel = level
	MS:Log(string.format("Level %d reached", level))
	for i, part in pairs(MS.ActiveStoryParts) do
		local ch = part.ActiveChapter
		if part.Chapters[ch].type == "level" and MS.playerLevel >= part.Chapters[ch].level then
			MS:Log(string.format("Level objective achieved, advancing chapter at %d.%d", part.DisplayNumber, ch))			
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		end
	end
end

function MS:HandleQuestAcceptedOrAbandoned(qid)
	for i, part in pairs(MS.ActiveStoryParts) do
		local ch = part.ActiveChapter
		MS:Log(string.format("Quest %d accepted or removed: checking against active chapter %d.%d/%d", qid, part.Id, ch, #part.Chapters))
		if part.Chapters[ch].type == "quest" and part.Chapters[ch].id == qid then
			MS:Log(string.format("Quest %d accepted or removed: relevant to part %d.%d", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS:SetPartFrameContent(part.Frame)
		elseif part.Chapters[ch].type == "quest" and part.Chapters[ch].breadcrumbTo == qid then
			MS:Log(string.format("Quest %d accepted or removed, this breadcrumb can be skipped %d.%d", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		elseif part.Chapters[ch].type == "quest-accept" and part.Chapters[ch].id == qid then
			MS:Log(string.format("Quest %d accept only, advance to next chapter", qid, part.Id, ch))
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		end
	end
end

function MS:HandleAchievementCompleted(achId)
	MS:AddNewActiveStoryParts()
	MS:Log(string.format("Achievement %d completed", achId))
	for i, part in pairs(MS.ActiveStoryParts) do
		local ch = part.ActiveChapter
		if (part.Chapters[ch].type == "raid" or part.Chapters[ch].type == "dungeon") and part.Chapters[ch].achId == achId then
			MS:Log(string.format("Achievement %d completed is relevant to part %d.%d", achId, part.DisplayNumber, ch))			
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		end
	end
end

function MS:HandleQuestTurnedIn(qid)
	MS:AddNewActiveStoryParts()
	MS:Log(string.format("Quest %d turned in", qid))
	self.QuestsCompleted[qid] = true
	for i, part in pairs(MS.ActiveStoryParts) do
		local ch = part.ActiveChapter
		if part.Chapters[ch].type == "quest" and part.Chapters[ch].id == qid then
			MS:Log(string.format("Quest %d turned in is relevant to part %d.%d", qid, part.DisplayNumber, ch))			
			part.Frame.AnimationOverlay.FlashAnimation:Play()
			MS_AdvanceChapter(part.Frame)
		end
	end
end

function MS:CreateNewPartFrame(part)
	local frame
	if #MSF.UnusedPartFrames > 0 then
		MS:Log(string.format("CreateFrame: %d unused frames", #MSF.UnusedPartFrames))
		frame = table.remove(MSF.UnusedPartFrames)
		MS:Log("CreateFrame: Chosen unused frame %s", frame:GetName())
	else
		frame = CreateFrame("Frame", addonName..(#MSF.PartFrames+1).."StoryPartFrame", MSF, "MS_ActiveStoryPart")
		local backdrop = {
			bgFile = "Interface/Buttons/WHITE8X8"
		}
		frame.AnimationOverlay:SetBackdrop(backdrop)
		frame.AnimationOverlay:SetBackdropColor(150/255, 250/255, 150/255)
		table.insert(MSF.PartFrames, frame)
		MS:Log(string.format("CreateFrame: Creating brand new frame (might be bad)", frame:GetName()))
	end
	part.Frame = frame
	frame.Part = part
	part.Frame.Complete:Hide()
	part.Frame.New:Show()
	frame.AnimationOverlay:SetAlpha(0)
	self.borderColor = db.classBorder and self.classColor or db.borderColor
	frame:SetPoint("TOPLEFT", 0, MSF:GetHeight()*-1)
	MSF:SetHeight(MSF:GetHeight() + frame:GetHeight())
	MS:SetPartFrameContent(frame)
	frame:Show()
	local group = part.Frame:CreateAnimationGroup()
	local animation = group:CreateAnimation("ALPHA")
	animation:SetFromAlpha(0)
	animation:SetToAlpha(1)
	animation:SetDuration(3)
	group:SetScript("OnFinished", function() frame:SetAlpha(1) part.Frame.New:Hide() end)
	group:Play()	
end

function MS:StartCompletePartAndRemoveFrame(part)
	MS:Log(string.format("Part name=%d id=%d is complete, removing from UI", part.DisplayNumber, part.Id))
	MS.CompletedStoryParts[part.Id] = true
	
	--table.remove(MS.ActiveStoryParts, tonumber(part.Id))
	MS.ActiveStoryParts[part.Id] = nil

	part.Frame.Complete:Show()
	part.Frame.ShowURL:Hide()
	part.Frame.Continue:Hide()
	local group = part.Frame:CreateAnimationGroup()
	local animation = group:CreateAnimation("ALPHA")
	animation:SetFromAlpha(1)
	animation:SetToAlpha(0)
	animation:SetDuration(3)
	group:SetScript("OnFinished", function() MS:FinishCompletePartAndRemoveFrame(part) end)
	group:Play()
end

function MS:FinishCompletePartAndRemoveFrame(part)
	local frame = part.Frame
	frame:Hide()
	table.insert(MSF.UnusedPartFrames, frame)
	part.Frame = nil
	frame.Part = nil
	-- Reposition all frames
	MSF:SetHeight(MSF:GetHeight() - frame:GetHeight())
	local offset = MSF.Header:GetHeight()
	for i, frame in pairs(MSF.PartFrames) do
		if frame:IsVisible() then
			frame:SetPoint("TOPLEFT", 0, offset*-1)
			offset = offset + frame:GetHeight()
		end
	end
	MS:AddNewActiveStoryParts()
end

function MS_AdvanceChapter(partFrame)
	local part = partFrame.Part
	if part.Chapters[part.ActiveChapter].type == "external-cinematic" or part.Chapters[part.ActiveChapter].type == "removed-content-recap" then
		MS:AddSkip(part)
	end

	local chapterSelected = false
	while not chapterSelected do
		part.ActiveChapter = part.ActiveChapter + 1
		if part.ActiveChapter > #part.Chapters then
			MS:Log(string.format("Advance chapter for part %d when on the last part (%d/%d)", part.DisplayNumber, part.ActiveChapter, #part.Chapters))
			MS:StartCompletePartAndRemoveFrame(part)
			chapterSelected = true		
		elseif not MS:IsChapterCompletedWeakTest(part.Id, part.Chapters[part.ActiveChapter], part.ActiveChapter) then
			MS:Log(string.format("Advance chapter for part %d to (%d/%d)", part.DisplayNumber, part.ActiveChapter, #part.Chapters))
			MS:SetPartFrameContent(partFrame)
			chapterSelected = true
		end
	end
end

function MS:SetPartFrameContent(frame)
	local part = frame.Part
	local ch = frame.Part.ActiveChapter

	MS:Log(string.format("Setting frame content for part %d.%d", part.DisplayNumber, ch))

	frame.ShowURL:Hide()
	frame.Continue:Hide()
	frame.Content:Hide()
	frame.ChapterTitle:Show()
	frame.PartTitle:SetText(string.format("Part %d: %s", part.DisplayNumber, part.Name));
	frame.ChapterTitle:SetText(string.format("Chapter %d: %s", ch, MS:GetChapterName(part.Chapters[ch])));
	frame.ProgressHolder.Progress:SetMinMaxValues(0, #part.Chapters)
	frame.ProgressHolder.Progress:SetValue(ch)
	frame.ProgressHolder.Progress.Text:SetText(string.format("Chapter %d of %d", ch, #part.Chapters));

	if part.Chapters[ch].hint then
		frame.Hint:Show()
		frame.Hint:SetText(part.Chapters[ch].hint)
	else
		frame.Hint:Hide()
	end

	if part.Chapters[ch].type == "quest" or part.Chapters[ch].type == "quest-accept" then
		if C_QuestLog.IsOnQuest(part.Chapters[ch].id) then
			frame.Instruction:SetText(string.format("Complete quest '%s'", MS:GetChapterName(part.Chapters[ch])))
		else
			frame.Instruction:SetText(string.format("Accept quest '%s'", MS:GetChapterName(part.Chapters[ch])))
		end
	elseif part.Chapters[ch].type == "external-cinematic" then
		frame.Instruction:SetText(string.format("This story cinematic must be viewed outside the game. Please copy the URL to watch the cinematic."))
		frame.ShowURL:Show()
		frame.Continue:Show()
	elseif part.Chapters[ch].type == "text" then
		frame.Instruction:SetText(string.format("Complete the instructions above to continue"))
	elseif part.Chapters[ch].type == "removed-content-recap" then
		frame.Instruction:SetText(string.format("This part of the story has been removed by Blizzard. Please copy the URL for a video recap of the removed content."))
		frame.ShowURL:Show()
		frame.Continue:Show()
	elseif part.Chapters[ch].type == "raid" then
		frame.Instruction:SetText(string.format("Enter the raid instance %s and defeat the final encounter, %s. This instance is relevant to the story, but can be skipped.", part.Chapters[ch].name, part.Chapters[ch].final))
	elseif part.Chapters[ch].type == "level" then
		frame.Instruction:SetText(string.format("Reach level %d to continue the story", part.Chapters[ch].level ))
	elseif part.Chapters[ch].type == "recap" then
		frame.Content:Show()
		frame.Content.ButtonText:SetText(part.Chapters[ch].button)
		frame.Continue:Show()
		frame.ChapterTitle:Hide()
	end
end

function MS:AddSkip(part)
	if not dbChar.skips then dbChar.skips = {} end
	if not dbChar.skips[part.Id] then dbChar.skips[part.Id] = {} end
	dbChar.skips[part.Id][part.ActiveChapter] = true
end

function MS:SetStoryPartFramesDisplayConfiguration()
	local backdrop = {
		edgeFile = LSM:Fetch("border", db.border),
		edgeSize = 12,
	}
	self.borderColor = db.borderColor

	for i, frame in pairs(MSF.PartFrames) do
		frame.ProgressHolder.Progress:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
		frame.ProgressHolder.Progress:SetStatusBarColor(0/255, 100/255, 200/255)
		frame.ProgressHolder:SetBackdrop(backdrop)
		frame.ProgressHolder:SetBackdropBorderColor(150/255, 150/255, 150/255)
	end
end

function MS:MoveStoryFrame()
	MSF:ClearAllPoints()
	MSF:SetPoint(db.anchorPoint, UIParent, db.anchorPoint, db.xOffset, db.yOffset)
end

function MS:SetBackground()
	local backdrop = {
		bgFile = LSM:Fetch("background", db.bgr),
		edgeFile = LSM:Fetch("border", db.border),
		edgeSize = db.borderThickness,
		insets = { left=db.bgrInset, right=db.bgrInset, top=db.bgrInset, bottom=db.bgrInset }
	}
	self.borderColor = db.classBorder and self.classColor or db.borderColor

	MSF:SetBackdrop(backdrop)
	MSF:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
	MSF:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)
end

-- Load ----------------------------------------------------------------------------------------------------------------

function MS:OnInitialize()
	MS:Log("Starting OnInitialize", true)
	SLASH_MAINSCENARIO1, SLASH_MAINSCENARIO2 = "/ms", "/mainscenario"
	SlashCmdList["MAINSCENARIO"] = SlashHandler

	-- Get character data
	self.playerName = UnitName("player")
	self.playerFaction = UnitFactionGroup("player")
	self.playerLevel = UnitLevel("player")
	local _, class = UnitClass("player")

	self.initialized = false

	-- Setup Options
	self:SetupOptions()
	db = self.db.profile
	dbChar = self.db.char

	-- wipe DB, very dangerous
	dbChar.skips = {}

	self.screenWidth = round(GetScreenWidth())
	self.screenHeight = round(GetScreenHeight())

	-- Fetch quests from server. Only do this once
	local quests = C_QuestLog.GetAllCompletedQuestIDs()
	self.QuestsCompleted = {}
	for i, questid in ipairs(quests) do
		self.QuestsCompleted[questid] = true
	end

	-- Decide which story to load. This will only change if the character zones
	MS:LoadStory()
	CreateStaticFrames()

	-- Calculate completed parts. Only do this once per story, as a completed part can never be un-completed
	MS:DetermineCompletedStoryParts()
	MS:PreloadQuestNames()

	-- Calculate active parts. Will be rechecked on quest/achievement completion
	self.ActiveStoryParts = {}
	MS:AddNewActiveStoryParts()

	MS:Log("MSAddon", MS)
	MS:Log("MSAddonFrame", MSF)
	MS:Log("ActiveStoryParts", MS.ActiveStoryParts)
	MS:Log("QuestsCompleted", MS.QuestsCompleted)
	MS:Log("CompletedStoryParts", MS.CompletedStoryParts)
end

function MS:LoadStory()
	local exp = self.GetExpansion()  
	self.ActiveStory = self.StoryData["0"..exp]
	if self.ActiveStory == nil then
		MS:Log("No story data for 0"..exp, nil)
	end
	MS:Log("Story data loaded for 0"..exp, nil)
end

function MS:PreloadQuestNames()
	if not self.ActiveStory then return end
	for i, part in pairs(self.ActiveStory.Parts) do
		if not self.CompletedStoryParts[i] then
			MS:Log(string.format("Preloading quest names for incomplete part %d", i))
			for j, chapter in pairs(part.Chapters) do
				MS:GetChapterName(chapter)
			end
		end
	end
end

function MS:DetermineCompletedStoryParts()
	self.CompletedStoryParts = {}
	if not self.ActiveStory then return end
	for i, part in pairs(self.ActiveStory.Parts) do
		if part:IsComplete() then
		--if false then
			MS:Log(string.format("Part %d: %s has been completed", part.DisplayNumber, part.Name), nil)
			self.CompletedStoryParts[i] = true
		end
	end
	MS:Log(string.format("Finished determining that %d parts are completed", #self.CompletedStoryParts))
end

function MS:AddNewActiveStoryParts()
	local partsAdded = 0
	if not self.ActiveStory then return 0 end
	for i, part in pairs(self.ActiveStory.Parts) do
		if not self.CompletedStoryParts[i] and not self:IsPartAlreadyActive(i) and MS:IsPartActive(part) then
			MS:Log(string.format("Part %d: %s is active", part.DisplayNumber, part.Name), nil)
			part.Id = i	
			MS:DetermineChapterForPart(part)
			partsAdded = partsAdded + 1
			table.insert(self.ActiveStoryParts, tonumber(i), part)
			MS:CreateNewPartFrame(part)
		end
	end
	MS:Log(string.format("Finished determining that %d parts are active, %d new parts added", #MS.ActiveStoryParts, partsAdded))
	return partsAdded
end

function MS:IsPartAlreadyActive(partId)
	for i, part in pairs(self.ActiveStoryParts) do
		if part.Id == partId then 
			MS:Log(string.format("Part %d is already in the active list", partId), self.ActiveStoryParts)
			return true 
		end
	end
	MS:Log(string.format("Part %d is NOT already in the active list", partId), self.ActiveStoryParts)
	return false
end

function MS:DetermineChapterForPart(part)
	local rollbackPoint 
	-- Scroll forward to first non completed quest, skipping content that cannot be determined by the API
	for j, chapter in pairs(part.Chapters) do 
		if not MS:IsChapterCompletedWeakTest(part.Id, chapter, j) or j == #part.Chapters then 				
			--rollbackPoint = j
			part.ActiveChapter = j
			MS:Log(string.format("Chapter setting: Chapter %d.%d is active", part.Id, j), nil)
			break 
		end
	end
	
	--MS:Log(string.format("Chapter setting: Chapter %d.%d is rollback point", part.Id, rollbackPoint), nil)
	-- Scroll back to first non-completed content of any type
	-- for j=rollbackPoint, 1, -1 do
	-- 	MS:Log(string.format("Rollback checking chapter %d %s", j, MS:GetChapterName(part.Chapters[j])), nil)
	-- 	if MS:IsChapterCompletedWeakTest(part.Id, part.Chapters[j], j) then
	-- 		part.ActiveChapter = j + 1
	-- 		MS:Log(string.format("Chapter setting: Chapter %d is active in part %d", part.ActiveChapter, part.DisplayNumber), nil)
	-- 	end
	-- end

	-- if not part.ActiveChapter then
	-- 	MS:Log(string.format("Chapter setting: No chapters complete, therefore Chapter 1 is active in part %d", part.DisplayNumber), nil)
	-- 	part.ActiveChapter = 1
	-- end
end

function MS:GetExpansion()
    return 8
    -- do this properly later
end

function MS:IsQuestCompleted(questId)
	title = C_QuestLog.GetTitleForQuestID(questId)
	if not title then title = "Unknown" end
	-- if self.QuestsCompleted[questId] then
	-- 	MS:Log(string.format("Quest %d: %s has been completed", questId, title), self.QuestsCompleted)
	-- else
	-- 	MS:Log(string.format("Quest %d: %s has not been completed", questId, title), self.QuestsCompleted)
	-- end
	return self.QuestsCompleted[questId]
end

function MS:IsAchievementCompleted(achId)
	local id, name, points, completed = GetAchievementInfo(achId)
	MS:Log(string.format("Achievement %d is completed? %s", achId, tostring(completed)))
	return completed
end

function MS:IsPartActive(part)
	if not part:RequirementsMet() then
		MS:Log(string.format("Part %d is not active because its requirements have not been met", part.DisplayNumber))
		return false
	end

	if part:RecommendationsMet() then
		MS:Log(string.format("Part %d is active because its recommendations are met", part.DisplayNumber, i))
		return true
	end

	return false
	-- -- this is expensive, maybe come back to it later
	-- for i, chapter in pairs(part.Chapters) do
	-- 	if MS:IsChapterCompletedStrongTest(chapter) then 
	-- 		MS:Log(string.format("Part %d is active because chapter %d has been completed", part.DisplayNumber, i))
	-- 		return true 
	-- 	end
	-- end

	-- return false
end

-- Strong test for determining if a part is active despite not being recommended content
-- Weak test for determining which chapter to display
function MS:IsChapterCompletedStrongTest(chapter)
	if chapter.type == "quest" then return MS:IsQuestCompleted(chapter.id) end
	-- Chapters completed by dungeons and raids should pass the test

	-- Chapters completed by cinematic, external content, text, rep or level should not pass the test
	return false
end

function MS:IsChapterCompletedWeakTest(part, chapter, chapterId)
	if chapter.type == "quest" then return MS:IsQuestCompleted(chapter.id) end
	if chapter.type == "quest-accept" then return MS:IsQuestCompleted(chapter.id) or C_QuestLog.IsOnQuest(chapter.id) end
	if chapter.type == "raid" or chapter.type == "dungeon" then return MS:IsAchievementCompleted(chapter.achId) end
	if chapter.type == "level" then return MS.playerLevel >= chapter.level end
	if chapter.type == "external-cinematic" or chapter.type == "removed-content-recap" then
		return MS:IsChapterSkipped(part, chapterId)
	end
	if chapter.type == "ingame-cinematic" or chapter.type == "removed-quest" then
		return true
	end
	return false
end

function MS:GetChapterName(chapter)
	if chapter.type == "quest" or chapter.type=="quest-accept" then 
		local name = C_QuestLog.GetTitleForQuestID(chapter.id)
		if not name then
			MS:Log(string.format("WARNING Failed to load quest name for questid %d", chapter.id))
		end
		return C_QuestLog.GetTitleForQuestID(chapter.id) or "Unknown"
	elseif chapter.type == "level" then
		return "Level up!"
	elseif chapter.name then
		return chapter.name
	end
	return "Unnamed chapter"
end

function MS:IsChapterSkipped(part, chapter)
	if not dbChar.skips then return false end
	if not dbChar.skips[part] then return false end
	if not dbChar.skips[part][chapter] then return false end
	return true
end

function MS:GetStringsTable()
	MS:Log("Getting strings table")
	return MS.StringsEN
end