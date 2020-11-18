local addonName, MS = ...

MS.StoryData["Horde08"] = 
{
    Title = "Battle for Azeroth - Horde",
    Parts = {
        [1]={
            DisplayNumber = "1",
            Name = "Battle for Azeroth Prologue",
            RequirementsMet = function() return MS.playerLevel >= 10 end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "external-cinematic", id = 1, url = "https://www.youtube.com/watch?v=aW_h0qf9vpA", name = "Old Soldier"},
                { type = "external-cinematic", id = 2, url = "https://www.youtube.com/watch?v=aW_h0qf9vpA", name = "Battle for Azeroth Intro"},
                { type = "quest", id = 53372, breadcrumbTo=51796, hint="If a class trial is active, complete the trial to automatically progress the story" },
                { type = "quest", id = 51796 },
                { type = "ingame-cinematic", id = 856, name="Battle for Lordaeron: Turn the Tide"},
                { type = "ingame-cinematic", id = 855, name="Lordaeron Throne Room Confrontation - Horde"},
            },
            IsComplete = function() return MS:IsQuestCompleted(51796) end,
        },
        [2]={
            DisplayNumber = "2",
            Name = "Battle for Azeroth Introduction",
            RequirementsMet = function() return MS.StoryData["Horde08"].Parts[1]:IsComplete() end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 53028},
                { type = "quest", id = 51211},
                { type = "quest", id = 52428},
                { type = "quest", id = 53031},
                { type = "quest", id = 51443},
                { type = "quest", id = 50769},
                { type = "ingame-cinematic", id = 857, name = "Arrival to Zandalar - Horde"},
                { type = "quest", id = 46957},
                { type = "quest", id = 46930},
                { type = "quest", id = 46931},
                { type = "quest", id = 52131},
                { type = "text", name="Select any zone on the map in the Great Seal in Zuldazar to progress to the next part of the story"},
            },
            IsComplete = function() return MS:IsQuestCompleted(47514) or MS:IsQuestCompleted(47512) or MS:IsQuestCompleted(47513) end,
        },
        [3]={
            DisplayNumber = "3",
            Name = "The Throne of Zuldazar",
            RequirementsMet = function() return MS:IsQuestCompleted(47514) end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 49615},
                { type = "quest", id = 49488},
                { type = "quest", id = 49489},
            },
            IsComplete = function() return MS:IsQuestCompleted(50963) end,
        },
        [100]={
            DisplayNumber = "100",
            Name = "War Campaign 8.2.0 (Rebel)",
            RequirementsMet = function() return MS:IsQuestCompleted(52131) end,
            RecommendationsMet = function() return true end,
            Chapters = {
                { type = "quest", id = 55778, name = "Visions of Danger"},
                { type = "quest", id = 55781, name = "Old Allies", giver = "Lor'themar Theron", zone = "Nazjatar", },
                { type = "quest", id = 55779, name = "Stay of Execution"},
            },
            IsComplete = function() return MS:IsQuestCompleted(55779) end,
        },
    },
}