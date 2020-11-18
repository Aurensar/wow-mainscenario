local addonName, MS = ...
local db, dbChar
local MSF = MS.frame
local LSM = LibStub("LibSharedMedia-3.0")
local borderColor, backdrop

function MS:SetupContentFrame()
    db = self.db.profile
	dbChar = self.db.char
    MSF.Content = CreateFrame("Frame", addonName.."ContentFrame", UIParent, "BackdropTemplate")
	MSF.Content:SetWidth(750)
	MSF.Content:SetMovable(true)
	MSF.Content:EnableMouse(true)
	MSF.Content:RegisterForDrag("LeftButton")
	MSF.Content:SetScript("OnDragStart", MSF.Content.StartMoving)
	MSF.Content:SetScript("OnDragStop", MSF.Content.StopMovingOrSizing)
    MSF.Content:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 500, -300)
    
    backdrop = {
		bgFile = LSM:Fetch("background", db.bgr),
		edgeFile = LSM:Fetch("border", db.border),
		edgeSize = db.borderThickness,
		insets = { left=db.bgrInset, right=db.bgrInset, top=db.bgrInset, bottom=db.bgrInset }
	}
	borderColor = db.classBorder and self.classColor or db.borderColor

    MSF.Content:SetBackdrop(backdrop)
    MSF.Content:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
    MSF.Content:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, db.borderAlpha)


    MSF.Content.Title = MSF.Content:CreateFontString(MSF.Content, "OVERLAY", "GameTooltipText")
    MSF.Content.Title:Show()
    MSF.Content.Title:SetJustifyV("CENTER");
    MSF.Content.Title:SetJustifyH("MIDDLE");
    MSF.Content.Title:SetPoint("TOPLEFT", MSF.Content, "TOPLEFT", 100, -10)
    MSF.Content.Title:SetPoint("TOPRIGHT", MSF.Content, "TOPRIGHT", -100, -10)

    MSF.Content.Close = CreateFrame("Button", addonName.."RecapCloseButton", MSF.Content, "GameMenuButtonTemplate")
    MSF.Content.Close:SetPoint("BOTTOMRIGHT", MSF.Content, "BOTTOMRIGHT", -10, 10)
    MSF.Content.Close:SetText("Close")
    MSF.Content.Close:SetHeight(20)
    MSF.Content.Close:SetWidth(80)
    MSF.Content.Close:SetScript("OnClick", function() MSF.Content:Hide() end)

    MSF.Content.RecapFrames = { }
end

function MS_ShowContent(frame)
    local part = frame.Part
    local ch = frame.Part.ActiveChapter
    
    for i, frame in pairs(MSF.Content.RecapFrames) do
        frame:Hide()
    end

    MSF.Content:Show()
    MSF.Content:SetHeight(80)
    MSF.Content.Title:SetText(part.Chapters[ch].title)
    local yOffset = -30

    for i, section in pairs(part.Chapters[ch].Sections) do
        local frame = MS:GetRecapFrame(i)
        frame:SetHeight(MS:CalculateContentSectionHeight(section.text))
        frame.RecapContent:SetHeight(frame:GetHeight() - 25)
        frame:SetPoint("TOPLEFT", 25, yOffset)
        yOffset = yOffset - frame:GetHeight()
        frame.RecapTitle:SetText(section.title)
        frame.RecapContent:SetText(section.text)
        frame:Show()
        if section.link then frame.GetURL:Show() else frame.GetURL:Hide() end
        if section.cinematic then frame.Cinematic:Show() else frame.Cinematic:Hide() end
        --frame:SetBackdrop(backdrop)
        --frame:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
        --frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, db.borderAlpha)
        frame.Section = section
        MSF.Content:SetHeight(MSF.Content:GetHeight() + frame:GetHeight())
    end
end

function MS:CalculateContentSectionHeight(copy)
    local height = 30
    local breaks = select(2, copy:gsub('\n', '\n'))
    height = height + (math.ceil(string.len(copy) / 110) * 15)
    height = height + (breaks * 10)
    MS:Log(string.format("Calculate height len=%d breaks=%d lines=%d height=%d", string.len(copy), breaks, string.len(copy) / 110, height))
    return height
end

function MS:GetRecapFrame(i)
    if MSF.Content.RecapFrames[i] then
        return MSF.Content.RecapFrames[i]
    end

    frame = CreateFrame("Frame", addonName..i.."RecapPartFrame", MSF.Content, "MS_StoryRecapPart")
    table.insert(MSF.Content.RecapFrames, frame)
    return frame
end