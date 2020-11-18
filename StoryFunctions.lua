local addonName, MS = ...

function MS:GetActiveStoryParts()

    local activeStoryParts = {}
    local expansionStoryComplete = false
    local exp = GetExpansion()
    local faction = UnitFactionGroup("player")
    MS:Log(faction.."0"..exp, nil)
    local storyDefinition = self.StoryData[faction.."0"..exp]
    

    return activeStoryParts, expansionStoryComplete
end

local function GetExpansion()
    return 8
    -- do this properly later
end
